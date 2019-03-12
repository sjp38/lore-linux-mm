Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 350E2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:31:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDEBC2075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:31:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDEBC2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81B378E0003; Tue, 12 Mar 2019 07:31:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CE218E0002; Tue, 12 Mar 2019 07:31:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BDC98E0003; Tue, 12 Mar 2019 07:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13B5D8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:31:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p5so973610edh.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EVlRH0+gEJXyYOABd9wCgNp8dfwryXyxmHM/EoDZXCU=;
        b=YQUfTpUxsAtiizowjL128kduLVFSpLtfmKAGdClqIDNRKWeoEUQUGfK6bnDvYhSF2+
         H4w4SglAaaddqWkI6+6mGB0T6BMuohUDpzjmks0ET5TLB46/CrfvvCM/reuBsgNrLg1H
         VqOridG3oqQa4rMf71NVGLHUWmQFxUPplQ8dyUPpCYi/ThZ9dUBFJSfvSQyu7xvEWoQ8
         S/n90fyahL5laX2NgnrCqyF/n0Hg6djCrozkPQzUTACrpzS4/TUSAzsq4tEvqp2ocCAz
         xYmlQiUWRZjPG70pS8dH7SRtdg2G3oddZ2bzEgWJySupif91vRAEvB1/IR2ENkji0YKi
         imhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWj6EPICFn1xRNWF6IGvliMizgHR1MUOkg25zIY1SYMbYbY1VPA
	xIJxCqN+icy+g1XTqmW07471TVIau/DlmrZzKz2ET4iIwZ8c/EXlLKuWewjULVTQsNBaBvqaQ4d
	RdYw90jG+KUSQ7UjNBwuFbcNScY3PynJrSci6lQMvBJdGoMJjR+kQn7DFfScY3txyGA==
X-Received: by 2002:a17:906:4f15:: with SMTP id t21mr25414261eju.179.1552390307682;
        Tue, 12 Mar 2019 04:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzx0XrNfCoq0Ui0mryd/Vye2uOKzdg5vvxisfNSNkNYqEaf7dBYotVmJ9VUaHxwjd2QlO1B
X-Received: by 2002:a17:906:4f15:: with SMTP id t21mr25414200eju.179.1552390306566;
        Tue, 12 Mar 2019 04:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552390306; cv=none;
        d=google.com; s=arc-20160816;
        b=DBfV0bxlye9hJfx2kzKgHL9yIvoQdB1PhqWxb9z1VZ/jaK+Q0SUWQm65RGPekkLbVW
         eXtjm+xMAHIq0fIkoX20F/lNWI04F/HmSrZvU11Vr01qTNG0/lDnLyLG6AiK1G/WOjym
         vTSgOw07TQHgH2cc44Te11e20YBNOEglb/RBbTLF0HSWp8OBUSfX6SPRoElNJVtLyCYn
         duh3DPiT/EGK7L9dY/IfkRzteO1MC/wf4E69tSmRkGDLr0V9ARii31glZaldAotRzpAV
         tvKgOKzTuxDPpueBOWotvoZexEOKA+P1FBnQm1gVBFTCNQLVg3c6FpYt4MJFEfL8fRiG
         WMEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EVlRH0+gEJXyYOABd9wCgNp8dfwryXyxmHM/EoDZXCU=;
        b=dUSBHI8psUDagIZwqbjhIxE4tsNR1idDbMSXOQUHooK31MSRpLu2eJCFaTesqespq2
         WmKUn4wdtuEdX1yzGwiChG5GE5zwEaxBcsV+1YvC5YwH5VRRmI/lf52CEsQHmE2WxiOC
         TINyCN4phNZng1jokWcWKUwXfCn3fTnbvcCmky9GpQF6PvaNKNDN5rd9mJYgwKEpWsY2
         yUTHC2moQXl9d3HXcfkizcVmbwCS9q5T8GJ+We3za5Fkh9jLnTu6CpJaGuPnhYRGGUbt
         g/+b4mXZTa7Ke4fMEx/TGYP3mkZM4wA69yQUJdtLBfk2ge0IuYwQ9WceHCpbp6v5uWuN
         nphg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k30si511724edb.244.2019.03.12.04.31.46
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 04:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7D50F374;
	Tue, 12 Mar 2019 04:31:45 -0700 (PDT)
Received: from [10.163.1.86] (unknown [10.163.1.86])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7CBF53F59C;
	Tue, 12 Mar 2019 04:31:41 -0700 (PDT)
Subject: Re: [PATCH] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
To: Suzuki K Poulose <suzuki.poulose@arm.com>, catalin.marinas@arm.com,
 will.deacon@arm.com, mark.rutland@arm.com, yuzhao@google.com
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
References: <20190312005749.30166-3-yuzhao@google.com>
 <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
 <5b82c7c4-93cc-2820-46ad-3fb731a0eefc@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <2d00c35d-ae10-ba4a-9b34-939fcf2b2f49@arm.com>
Date: Tue, 12 Mar 2019 17:01:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <5b82c7c4-93cc-2820-46ad-3fb731a0eefc@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/12/2019 04:07 PM, Suzuki K Poulose wrote:
> Hi Anshuman,
> 
> On 12/03/2019 02:19, Anshuman Khandual wrote:
>> ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
>> or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
>> PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
>> via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
>> pte_free_kernel(). These will fail once they start calling into pgtable_
>> [pmd]_page_dtor() for pages which never originally went through respective
>> constructor functions. Hence convert all stage-2 page table page release
>> functions to call buddy directly while freeing pages.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>   arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
>>   arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
>>   virt/kvm/arm/mmu.c                      | 2 +-
>>   3 files changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
>> index de2089501b8b..417a3be00718 100644
>> --- a/arch/arm/include/asm/stage2_pgtable.h
>> +++ b/arch/arm/include/asm/stage2_pgtable.h
>> @@ -32,14 +32,14 @@
>>   #define stage2_pgd_present(kvm, pgd)        pgd_present(pgd)
>>   #define stage2_pgd_populate(kvm, pgd, pud)    pgd_populate(NULL, pgd, pud)
>>   #define stage2_pud_offset(kvm, pgd, address)    pud_offset(pgd, address)
>> -#define stage2_pud_free(kvm, pud)        pud_free(NULL, pud)
>> +#define stage2_pud_free(kvm, pud)        free_page((unsigned long)pud)
> 
> That must be a NOP, as we don't have pud on arm32 (we have 3 level table).
> The pud_* helpers here all fallback to the generic no-pud helpers.
Which is the following here for pud_free()

#define pud_free(mm, x)                         do { } while (0)

On arm64 its protected by kvm_stage2_has_pud() helper before calling into pud_free().
In this case even though applicable pud_free() is NOP, it is still misleading. If we
are sure about page table level will always remain three it can directly have a NOP
(do/while) in there.

