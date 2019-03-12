Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A37BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB7EE206DF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:43:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB7EE206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0FA8E0003; Tue, 12 Mar 2019 07:43:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 450208E0002; Tue, 12 Mar 2019 07:43:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 367BA8E0003; Tue, 12 Mar 2019 07:43:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D55B58E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:43:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h16so968306edq.16
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=11vT0ckcw51NIh+LdNfv62oyMS0n/1I9czV3Y59gn58=;
        b=NgvXlH2zsoFFPBk8HQVzOHdb5G2UvGuES4qKB+/h4noJVzaiOeEYUItIEKef+5Q0Nc
         vQKmwuZjdNqRwUKeL5E0lE7RW5VUemdSAz0Hol2OBnjXm+tPtfNyZ4hscQFnxFoWDCWb
         kl6KB5N41vb9ixjsKYkPoSgo7E1Y2uV9vdCXJkawGINcA3pCktfyXEeDCAx5Hf0ojGKD
         BO7qGww3Hm3CMiEXNBt01FtoAxP0Oeu+b9Gc3sUfZjhjQ4X1suOGtMK6fXFp4Tf0CO6V
         1SoXlregCqQkWd/PbotStj0DGjAOBheKHdqPjd0XIjmJmu2ZprS9oVs21KSQ+KQFBeSJ
         O0QQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
X-Gm-Message-State: APjAAAUPLkYQBGE84ML2/wZkynGiHTdEIGqSaKECIEiHHa2eoKJj+lZM
	MTKxNPr/9sBm1El36NkYmjR7XoJVEhj5+xpW5jq+dEv/LsGzNW87frzt8eXcWMNwR4g8j1/nj2C
	hPqmUA5vyBdr36SK0bDzN5h5IGRDkf8a3t98H6a7Sui2VUGcMDz057NNox6MRDUx+sQ==
X-Received: by 2002:a05:6402:1817:: with SMTP id g23mr3013062edy.295.1552390988378;
        Tue, 12 Mar 2019 04:43:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwu1l/5ywe5cP/Fo14m8kr+/tA5/8uPGNPkVxiYyTUQJYjWv6PhE8GduxQbJylhjTy8n+XN
X-Received: by 2002:a05:6402:1817:: with SMTP id g23mr3013010edy.295.1552390987551;
        Tue, 12 Mar 2019 04:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552390987; cv=none;
        d=google.com; s=arc-20160816;
        b=Ti+eWSTUAii8INt4hYWZLCA1Tz6GibhaZr9TZsjtqXO67eJppu77MUomTsTgjSBG6U
         of4PAVbkB7btlg3J9PhvWsDZSFY8/sHhC2Y/qsinIevN5fb5CZ/cPanM3EekEUj47e0J
         eTzkbEWWnmSDLIkvTdrTV6bGLB21QV/tWs5wrvRwVNyDR/qQCeGzyw7ZTbshYleyf6A0
         ci9wuaYoY+6nMsloQq0zWS037xeT8/yfTIVCqA2orwgo+kC1LvDyR7UozSfn7+hgrKpF
         AsCaro39bLACjWY6qHbGfRGraNqNo3s8/yr670hzlOKOTPCKXf/1hyYyBALeaDn/z8uQ
         dePA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=11vT0ckcw51NIh+LdNfv62oyMS0n/1I9czV3Y59gn58=;
        b=kZ5qrnG0JDchEH9pCSSox+22ug77vvsHib2aFpFqpS1acX/MadzbdU/N1ve+UFCPAE
         eNrF/SpLMVSTBQBoobwvabGBy70y/sre0zF1x5L9jEdZvGfQS0ko+ORoWkLEbVOi+88p
         1MfXuAIlc0wP2sOs2S5AR8BWOAIEOWmolaDe+N8CAv78FEiiqu8HHOTU9ChP7IoUzebN
         yoEM7L21TGtNNd5ycgmCHX8y/1Xlu0ko8DlsWwtvXq6WkJETeDAnBqY97ONFiXu3HSyI
         HjeMl1bbo6fYiXAhD5JbaERgqjRIkxtXinUBgsSx6qfTZVVHuKXFwmGUomn/XrLHyYuG
         sTFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r2si3377050ejf.139.2019.03.12.04.43.07
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 04:43:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 521B1374;
	Tue, 12 Mar 2019 04:43:06 -0700 (PDT)
Received: from [10.1.196.93] (en101.cambridge.arm.com [10.1.196.93])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 349683F59C;
	Tue, 12 Mar 2019 04:43:04 -0700 (PDT)
Subject: Re: [PATCH] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
To: anshuman.khandual@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
 mark.rutland@arm.com, yuzhao@google.com
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
References: <20190312005749.30166-3-yuzhao@google.com>
 <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
 <5b82c7c4-93cc-2820-46ad-3fb731a0eefc@arm.com>
 <2d00c35d-ae10-ba4a-9b34-939fcf2b2f49@arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
Date: Tue, 12 Mar 2019 11:43:02 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <2d00c35d-ae10-ba4a-9b34-939fcf2b2f49@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 12/03/2019 11:31, Anshuman Khandual wrote:
> 
> 
> On 03/12/2019 04:07 PM, Suzuki K Poulose wrote:
>> Hi Anshuman,
>>
>> On 12/03/2019 02:19, Anshuman Khandual wrote:
>>> ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
>>> or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
>>> PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
>>> via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
>>> pte_free_kernel(). These will fail once they start calling into pgtable_
>>> [pmd]_page_dtor() for pages which never originally went through respective
>>> constructor functions. Hence convert all stage-2 page table page release
>>> functions to call buddy directly while freeing pages.
>>>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>>    arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
>>>    arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
>>>    virt/kvm/arm/mmu.c                      | 2 +-
>>>    3 files changed, 5 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
>>> index de2089501b8b..417a3be00718 100644
>>> --- a/arch/arm/include/asm/stage2_pgtable.h
>>> +++ b/arch/arm/include/asm/stage2_pgtable.h
>>> @@ -32,14 +32,14 @@
>>>    #define stage2_pgd_present(kvm, pgd)        pgd_present(pgd)
>>>    #define stage2_pgd_populate(kvm, pgd, pud)    pgd_populate(NULL, pgd, pud)
>>>    #define stage2_pud_offset(kvm, pgd, address)    pud_offset(pgd, address)
>>> -#define stage2_pud_free(kvm, pud)        pud_free(NULL, pud)
>>> +#define stage2_pud_free(kvm, pud)        free_page((unsigned long)pud)
>>
>> That must be a NOP, as we don't have pud on arm32 (we have 3 level table).
>> The pud_* helpers here all fallback to the generic no-pud helpers.
> Which is the following here for pud_free()
> 
> #define pud_free(mm, x)                         do { } while (0)
> 
> On arm64 its protected by kvm_stage2_has_pud() helper before calling into pud_free().
> In this case even though applicable pud_free() is NOP, it is still misleading. If we
> are sure about page table level will always remain three it can directly have a NOP
> (do/while) in there.
> 

Yes, it is fixed for arm32 and you could have it as do {} while (0), which is
what I meant by NOP. On arm64, we had varied number of levels depending on the
PAGE_SIZE and now due to the dynamic IPA, hence the check.

Cheers
Suzuki

