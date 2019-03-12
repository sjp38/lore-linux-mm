Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A516C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 10:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F49020449
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 10:37:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F49020449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CACE8E0003; Tue, 12 Mar 2019 06:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0539E8E0002; Tue, 12 Mar 2019 06:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5EEB8E0003; Tue, 12 Mar 2019 06:37:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8837B8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 06:37:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k21so900179eds.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:37:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Z1k/I+a9ysUE55mD4bf8R56mFDe27wL1ClBMSKt65mI=;
        b=ZNX6vGjGPcuBNQZtY9t4ZUgkff+M3vudb0L/OhIeclRO21SFtbXzXr3NL+2hVOGmg9
         o2zVUS7RNdsvPUfbjiM8TNfxL5xE//4YkTWxe7z3B4XBqodt9yM0Rl0HjvJb5AqClok5
         psc4bA/Js8jIgtX5pqLNqjxXyW/H1Xpr05DiwoMnPi999St+ZZIMqEgsitB7g4045n0y
         PhJ76ImMDRBB0+pAJUak8jIntl7bqcGMyzc/9lDyjJ40dMajrf7a6YAQFZcoNH2CE7D9
         m3SYaQLOUZPTontjfu+QLTRQGrKmKHHyPuVHUAqfitpXiV4fQqcr/BHV3D5i9hgcqidu
         vpwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
X-Gm-Message-State: APjAAAVooDp5NOpCMzX4ZOJt1hVUph/sz2G2yNJj3MdAjlqoSF+uCgDh
	BWVAmjO9H7kZFlFzZKy1ZIc2uNzm8CRGcL3qUF1cvhiPWpFHcayEc+oQfymXkeQOy/Br12QgRzb
	sFrB7Vmd7TepLgTTmdLWZCNhjFsNkReztxQKVbhQ+NAEp/kCuRCg8WTKYJnQxB9N/wQ==
X-Received: by 2002:a17:906:d0ce:: with SMTP id bq14mr4848026ejb.33.1552387034994;
        Tue, 12 Mar 2019 03:37:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxewK9xkLohaRaIZqW3RotNpI+Xn+rI3C+J+XsMsA8QRu5d4NLWAEOC1ErFJN5cV6C5mAN/
X-Received: by 2002:a17:906:d0ce:: with SMTP id bq14mr4847960ejb.33.1552387033501;
        Tue, 12 Mar 2019 03:37:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552387033; cv=none;
        d=google.com; s=arc-20160816;
        b=Ug5+2/zbhWJQ/+tJ5dUxu1GUUf/VEb7pxHmR5bIr42QNI4Jw+BM0Ccxh3ikfIFoBcS
         fGwrWGKXC9TEzHpo1UQgag/PqiwIOI9QV+1E+A8+3rLWEBVWTg2U8lSlGYmB4C2gEhA5
         9IFB/CD9VLWliQADLj087pkKtzpo+4VZBK/WxuEqP2HLMKAa/d6LERs6PDlVyeGRXVZF
         elK6jQzIPzaI59MRs3k2MSNREsfVkDZ9hHiguH+7TTM+6pe/VhfFth1u9x9VAJztnBbg
         SxrEe+id3q91fR9s8Gr0YLlNEj7AP3u6Qxb5Gp8bfbywZPJMlWLIY6Lx5DIbu3tICF6g
         lMZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Z1k/I+a9ysUE55mD4bf8R56mFDe27wL1ClBMSKt65mI=;
        b=LfK0ZhPjiGBcD0u+34GWapesLBpMkrUxUCOJNKc0z71jXS10eeDISWcFhyR3Iu2KXs
         AGuZ0toAYjAQJh5a1k2ldxLtd0PVNQd3Ul0hQ8TSoCRNJA1cZ3w3lfXYVSQwDRoCz9Nv
         GAZiUfZvbagfcFmw7CBMmo5Ppkta8e0fEx0LcxyhVIHXDleRvWrLMlkMPpCraW+rdVzL
         dZSdNZljXposFB07at3DU4xjtLb9eZnicErgIDvd4v4i0KOdkm6D5Ou7HQ3bJXiIPG7q
         NgFPzjLpbgMxJRNLgq2rpF0egvZrsP0vRYCnbH3OeG4KDQ2bzIYnwY6a8oayQM1vHtdY
         zOUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id dt11si135486ejb.118.2019.03.12.03.37.12
        for <linux-mm@kvack.org>;
        Tue, 12 Mar 2019 03:37:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of suzuki.poulose@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=suzuki.poulose@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 08A2CA78;
	Tue, 12 Mar 2019 03:37:12 -0700 (PDT)
Received: from [10.1.196.93] (en101.cambridge.arm.com [10.1.196.93])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A29B93F59C;
	Tue, 12 Mar 2019 03:37:10 -0700 (PDT)
Subject: Re: [PATCH] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
To: anshuman.khandual@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
 mark.rutland@arm.com, yuzhao@google.com
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
References: <20190312005749.30166-3-yuzhao@google.com>
 <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <5b82c7c4-93cc-2820-46ad-3fb731a0eefc@arm.com>
Date: Tue, 12 Mar 2019 10:37:08 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <1552357142-636-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On 12/03/2019 02:19, Anshuman Khandual wrote:
> ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
> or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
> PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
> via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
> pte_free_kernel(). These will fail once they start calling into pgtable_
> [pmd]_page_dtor() for pages which never originally went through respective
> constructor functions. Hence convert all stage-2 page table page release
> functions to call buddy directly while freeing pages.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>   arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
>   arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
>   virt/kvm/arm/mmu.c                      | 2 +-
>   3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
> index de2089501b8b..417a3be00718 100644
> --- a/arch/arm/include/asm/stage2_pgtable.h
> +++ b/arch/arm/include/asm/stage2_pgtable.h
> @@ -32,14 +32,14 @@
>   #define stage2_pgd_present(kvm, pgd)		pgd_present(pgd)
>   #define stage2_pgd_populate(kvm, pgd, pud)	pgd_populate(NULL, pgd, pud)
>   #define stage2_pud_offset(kvm, pgd, address)	pud_offset(pgd, address)
> -#define stage2_pud_free(kvm, pud)		pud_free(NULL, pud)
> +#define stage2_pud_free(kvm, pud)		free_page((unsigned long)pud)

That must be a NOP, as we don't have pud on arm32 (we have 3 level table).
The pud_* helpers here all fallback to the generic no-pud helpers.

>   
>   #define stage2_pud_none(kvm, pud)		pud_none(pud)
>   #define stage2_pud_clear(kvm, pud)		pud_clear(pud)
>   #define stage2_pud_present(kvm, pud)		pud_present(pud)
>   #define stage2_pud_populate(kvm, pud, pmd)	pud_populate(NULL, pud, pmd)
>   #define stage2_pmd_offset(kvm, pud, address)	pmd_offset(pud, address)
> -#define stage2_pmd_free(kvm, pmd)		pmd_free(NULL, pmd)
> +#define stage2_pmd_free(kvm, pmd)		free_page((unsigned long)pmd)
>   
>   #define stage2_pud_huge(kvm, pud)		pud_huge(pud)
>   
> diff --git a/arch/arm64/include/asm/stage2_pgtable.h b/arch/arm64/include/asm/stage2_pgtable.h
> index 5412fa40825e..915809e4ac32 100644
> --- a/arch/arm64/include/asm/stage2_pgtable.h
> +++ b/arch/arm64/include/asm/stage2_pgtable.h
> @@ -119,7 +119,7 @@ static inline pud_t *stage2_pud_offset(struct kvm *kvm,
>   static inline void stage2_pud_free(struct kvm *kvm, pud_t *pud)
>   {
>   	if (kvm_stage2_has_pud(kvm))
> -		pud_free(NULL, pud);
> +		free_page((unsigned long)pud);
>   }
>   
>   static inline bool stage2_pud_table_empty(struct kvm *kvm, pud_t *pudp)
> @@ -192,7 +192,7 @@ static inline pmd_t *stage2_pmd_offset(struct kvm *kvm,
>   static inline void stage2_pmd_free(struct kvm *kvm, pmd_t *pmd)
>   {
>   	if (kvm_stage2_has_pmd(kvm))
> -		pmd_free(NULL, pmd);
> +		free_page((unsigned long)pmd);
>   }
>   
>   static inline bool stage2_pud_huge(struct kvm *kvm, pud_t pud)
> diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> index e9d28a7ca673..00bd79a2f0b1 100644
> --- a/virt/kvm/arm/mmu.c
> +++ b/virt/kvm/arm/mmu.c
> @@ -191,7 +191,7 @@ static void clear_stage2_pmd_entry(struct kvm *kvm, pmd_t *pmd, phys_addr_t addr
>   	VM_BUG_ON(pmd_thp_or_huge(*pmd));
>   	pmd_clear(pmd);
>   	kvm_tlb_flush_vmid_ipa(kvm, addr);
> -	pte_free_kernel(NULL, pte_table);
> +	__free_page(virt_to_page(pte_table));
>   	put_page(virt_to_page(pmd));
>   }
>   

With that fixed,

Reviewed-by: Suzuki K Poulose <suzuki.poulose@arm.com>

