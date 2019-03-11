Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19273C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:57:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C74982084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:57:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C74982084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D97C8E0003; Mon, 11 Mar 2019 08:57:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55F818E0002; Mon, 11 Mar 2019 08:57:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4011B8E0003; Mon, 11 Mar 2019 08:57:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D64CD8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:57:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h37so2013722eda.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:57:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1q4ihnr11LykE9o1evwAkt5htWvWqDEGL5yyE8V/PKQ=;
        b=c7/O/umye3Q3dexmhWzbkNx82FzDcmWcxeFwwpkB7C0BMv22+iIyzSE4Da8Ga4bo1p
         Kw91PuoVYTNZ2BS7Z2RH5FQl8M5LT0YgugLxNDVR3cwc83d1436ofzQVqxa2dz1dDQvf
         CBW213dvil9FF+J2Yd+fw0OiwsfcZZw66nBJ/8VCRDV1MPwJf8IUXC6T80gSTxbWWL76
         ET3p/YlMUh9hW5EPfhd+BGT1m4wO79mp3OTcWF4SPbi7+iHv8flPAE4uuGfD2BRFRaFz
         sX/oWWupbWGdO86ieT/u5akeNwwGcSyTp4auB24rs/GN/W1AVtomGjWphztl8IaLV7nv
         a1lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWEYEX6Dyhe1tUfqvkov+tKNHQaKaPl/E4iUkbdtEigfBsl6ZHt
	s2dabNOUTmYZClHTxoh7ZsBFYm8Jn+efguQ3sN5bcwZe8KPTC20+XbqGF4yPtM+tQRfjY5PBAIq
	FnOpNiXzHf2P/KbtBwRTp2y3gsAUHy9bcD0DKE9M9r+1jAX6AMkNAs7gnXNmcNeLNOw==
X-Received: by 2002:a17:906:6c12:: with SMTP id j18mr20610912ejr.99.1552309052292;
        Mon, 11 Mar 2019 05:57:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeGTp2xW2lw21eSCOW7oyU/+O6+qhfKBEaUr9YFHdkJOYE1YM5gyokAADDlRkttuDEUDsz
X-Received: by 2002:a17:906:6c12:: with SMTP id j18mr20610861ejr.99.1552309051241;
        Mon, 11 Mar 2019 05:57:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552309051; cv=none;
        d=google.com; s=arc-20160816;
        b=fBY30zjnWh2RoxkIya3OX058RXkEZ/GrDnWGig6BT6Z0gCsJIjJs4DI3JJYg4FBumT
         WvxyL8G9OYdZC1c/4vHfaaibodDh2uVfD9FX+ELsSO7dKqlVHSXZ9f7ICT+ef6Fajt5G
         296+bQu8+eaAvl0aFDZF6mxhp0gr0RKJzcb2jQxfiphAZKDkgw0Wmbs4b1eWB11BPKYA
         v1oeRhu/omMokgoBvryrS9P+a7w584JhCwHnsOq/JMCljpxUgeFF/hlQSf0A7BfoDE6H
         hDCVQbnwy/ge4PPVssA8HxiQ6m4efbkxkQu26naCVd698UH7Jq1BqYBiEqW+mDgM+nbc
         gnhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1q4ihnr11LykE9o1evwAkt5htWvWqDEGL5yyE8V/PKQ=;
        b=CyTz6KbXp/Qi779mG4tJY1JMUdo7ATaLiub8yv9FpZQql7lErKGEpBejyPlUgH9cKA
         yOyF+VEe3sO31uyLxL/H8QfFrNogmulxnWzofmmkJXg8FeWe5DrZG2MaDEAgPWyhEO0s
         bqWt7q6bnzLoXyttK7x55MVwCToRL93jtxXNcw8flmezKyOWciapec41IYXyU5LTKDEZ
         /DfE6UqDECnl+HfJeU5sXWxgaryYKW9JVyzwHUBFaxkfmiVjw5vedXa6QjFihMsZwbmu
         rn8XFfErb5tJtkByCpxYL1y3FiiFpijY5wg91a4HhcYwqsd/FUoRqOF0Xqo3Xwkoapb9
         /19Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a8si352792eje.35.2019.03.11.05.57.30
        for <linux-mm@kvack.org>;
        Mon, 11 Mar 2019 05:57:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F178FA78;
	Mon, 11 Mar 2019 05:57:29 -0700 (PDT)
Received: from [10.163.1.86] (unknown [10.163.1.86])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 058B03F703;
	Mon, 11 Mar 2019 05:57:22 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] arm64: mm: enable per pmd page table lock
To: Mark Rutland <mark.rutland@arm.com>, Yu Zhao <yuzhao@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>,
 Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
 <20190310011906.254635-3-yuzhao@google.com>
 <20190311121147.GA23361@lakrids.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c567eb7f-40ca-ae20-94c3-5f48c9780f96@arm.com>
Date: Mon, 11 Mar 2019 18:27:19 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190311121147.GA23361@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/11/2019 05:42 PM, Mark Rutland wrote:
> Hi,
> 
> On Sat, Mar 09, 2019 at 06:19:06PM -0700, Yu Zhao wrote:
>> Switch from per mm_struct to per pmd page table lock by enabling
>> ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
>> large system.
>>
>> I'm not sure if there is contention on mm->page_table_lock. Given
>> the option comes at no cost (apart from initializing more spin
>> locks), why not enable it now.
>>
>> We only do so when pmd is not folded, so we don't mistakenly call
>> pgtable_pmd_page_ctor() on pud or p4d in pgd_pgtable_alloc(). (We
>> check shift against PMD_SHIFT, which is same as PUD_SHIFT when pmd
>> is folded).
> 
> Just to check, I take it pgtable_pmd_page_ctor() is now a NOP when the
> PMD is folded, and this last paragraph is stale?
> 
>> Signed-off-by: Yu Zhao <yuzhao@google.com>
>> ---
>>  arch/arm64/Kconfig               |  3 +++
>>  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
>>  arch/arm64/include/asm/tlb.h     |  5 ++++-
>>  3 files changed, 18 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index cfbf307d6dc4..a3b1b789f766 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
>>  config ARCH_HAS_CACHE_LINE_SIZE
>>  	def_bool y
>>  
>> +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>> +	def_bool y if PGTABLE_LEVELS > 2
>> +
>>  config SECCOMP
>>  	bool "Enable seccomp to safely compute untrusted bytecode"
>>  	---help---
>> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
>> index 52fa47c73bf0..dabba4b2c61f 100644
>> --- a/arch/arm64/include/asm/pgalloc.h
>> +++ b/arch/arm64/include/asm/pgalloc.h
>> @@ -33,12 +33,22 @@
>>  
>>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>>  {
>> -	return (pmd_t *)__get_free_page(PGALLOC_GFP);
>> +	struct page *page;
>> +
>> +	page = alloc_page(PGALLOC_GFP);
>> +	if (!page)
>> +		return NULL;
>> +	if (!pgtable_pmd_page_ctor(page)) {
>> +		__free_page(page);
>> +		return NULL;
>> +	}
>> +	return page_address(page);
>>  }
>>  
>>  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
>>  {
>>  	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
>> +	pgtable_pmd_page_dtor(virt_to_page(pmdp));
>>  	free_page((unsigned long)pmdp);
>>  }
> 
> It looks like arm64's existing stage-2 code is inconsistent across
> alloc/free, and IIUC this change might turn that into a real problem.
> Currently we allocate all levels of stage-2 table with
> __get_free_page(), but free them with p?d_free(). We always miss the
> ctor and always use the dtor.
> 
> Other than that, this patch looks fine to me, but I'd feel more
> comfortable if we could first fix the stage-2 code to free those stage-2
> tables without invoking the dtor.

Thats right. I have already highlighted this problem.
 
> 
> Anshuman, IIRC you had a patch to fix the stage-2 code to not invoke the
> dtors. If so, could you please post that so that we could take it as a
> preparatory patch for this series?

Sure I can after fixing PTE level pte_free_kernel/__free_page which I had
missed in V2.

https://www.spinics.net/lists/arm-kernel/msg710118.html

