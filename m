Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6EDCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 11:00:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 546B22082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 11:00:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 546B22082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E26C16B0003; Thu, 28 Mar 2019 07:00:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAF2B6B0006; Thu, 28 Mar 2019 07:00:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C50896B0007; Thu, 28 Mar 2019 07:00:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 71C0B6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 07:00:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w27so7952749edb.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 04:00:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GX0GvPcm7aaP46p8tpbgu01T/ZJB63R8khw69cSRiKo=;
        b=h7SP0f5/ssn8WWmx8YeUydrpWIaczGXdGwhDVPIBlOs5BcMVCDQg3sSzohAyJfmeYd
         w1mv3NSHuIDGu1t8UP7mdR/q0iTdad679kKSp1yS0qxU9//bzuQwvYWg2rtYpMEE23zz
         gQ3S5Nne52sxSOri9/wrek6m7mFDpT2HoaLiQS2FW8MGlgWB7SBEGV0k6aiOaKTNlWMd
         dvqdXRuEwoekpN3QlhTesykRGoXB0l5pMQW3YrRckX9wERDdkQIrMNHGE9lEwnQMK2Wt
         3IoGrBri1wForkcK8DyTXZesK3mmwhtsjdksAIp761Og2s6m+Ddeu9wtKonU6Ou30T+D
         qPWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWL38fBB+zJpcnjESTWCBaldxt0ELEX1N9wzJnJiV9PawCsKx2B
	ozzOjOlMYIRoPfD5zfEFCbXuRGnFvPKpH/O7YModOMdbrqFkt4X1VtsK+Z6sEiN/RzuvUGTNklA
	nNqpzTEaB97pQm+rbKy5hlHrOHMfab300YZpPsniv/CQAbvRXJaXITeljXoMbFODziQ==
X-Received: by 2002:a50:9a02:: with SMTP id o2mr15501575edb.182.1553770849960;
        Thu, 28 Mar 2019 04:00:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0A9590TF5z1elKr/qWOdTsek1lK++pyDgeLfkb5GTnfIwgk0utBhR75j6Oe93olQ58sqF
X-Received: by 2002:a50:9a02:: with SMTP id o2mr15501529edb.182.1553770849020;
        Thu, 28 Mar 2019 04:00:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553770849; cv=none;
        d=google.com; s=arc-20160816;
        b=Vh5PnumERgMiO9VQGnfvqcZcPoT1tneYVdy8KVgXiai/Jk47xMf6zyTJdpOfz1a5sM
         0wuBBZ5GUIEe79UBGH7VMkwI5XAw6ZKniwYqAtrXnDGYVf0Hh1rYcqndg7aJEValFUBY
         5p3bE36HuIo6eHZfNWrwPMhXvTpgQgpbNuvlV2wOzR+sx8R80NpbTeTx5PzV6OYP7Q4f
         I2KaWSi9HH9M0oxlRmISIUKLDyEjGEiHIiYhurFK4Yu7u34QAQfOFqatphSJpK7227kT
         Kk6QY2kQ6LVi9RueGJ/0oaJyjfvFV6cgN/TrKnR5FmD0GKzRjdjbzFI79PFkRVykvAxN
         as/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GX0GvPcm7aaP46p8tpbgu01T/ZJB63R8khw69cSRiKo=;
        b=Y1DuxIc2zsejgYRROmax3Gh5ad4Y5LMlcaiSrm6fQD/p77yV0scOq8+Z6IBrE3ZSSH
         Gzsgf205lEedjpvxxg/Rzv0Ya2loKKLFz2Vu6JvDTwFHF/Msng04F0apj44jflTGa7w7
         L0hoZgJ0BHFZjDz9vDqtoGNVjVEuXLNbCsna5KgEo7u5IRvJn7QQy8hR4UXlzGwx+ZCD
         8pxyozKu+ONMELxmRbRsiUxjJqlsppcGxYSLejRyPNZ46TL9yLSOS+/Hjvxrv+xoKzJ9
         QgJeRdEmD3AoJ6JvEob8WOKJTan1004xXxUAMNg5m5mBWOXBvURYK6hisYVBwVfns/nL
         zQjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u29si642623edm.86.2019.03.28.04.00.48
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 04:00:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C8DD415AB;
	Thu, 28 Mar 2019 04:00:47 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 04B733F59C;
	Thu, 28 Mar 2019 04:00:43 -0700 (PDT)
Subject: Re: [PATCH v6 04/19] powerpc: mm: Add p?d_large() definitions
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 James Morse <james.morse@arm.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 kvm-ppc@vger.kernel.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 Paul Mackerras <paulus@samba.org>, Andy Lutomirski <luto@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190326162624.20736-1-steven.price@arm.com>
 <20190326162624.20736-5-steven.price@arm.com>
 <8a2efe07-b99f-3caa-fab9-47e49043bf66@c-s.fr>
From: Steven Price <steven.price@arm.com>
Message-ID: <2b7d32ce-f258-1b34-1dbf-3a05ea9a0f6b@arm.com>
Date: Thu, 28 Mar 2019 11:00:42 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <8a2efe07-b99f-3caa-fab9-47e49043bf66@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26/03/2019 16:58, Christophe Leroy wrote:
> 
> 
> Le 26/03/2019 à 17:26, Steven Price a écrit :
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For powerpc pmd_large() was already implemented, so hoist it out of the
>> CONFIG_TRANSPARENT_HUGEPAGE condition and implement the other levels.
>>
>> Also since we now have a pmd_large always implemented we can drop the
>> pmd_is_leaf() function.
> 
> Wouldn't it be better to drop the pmd_is_leaf() in a second patch ?

Fair point, I'll split this patch.

Thanks for the review,

Steve

> Christophe
> 
>>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: Michael Ellerman <mpe@ellerman.id.au>
>> CC: linuxppc-dev@lists.ozlabs.org
>> CC: kvm-ppc@vger.kernel.org
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>   arch/powerpc/include/asm/book3s/64/pgtable.h | 30 ++++++++++++++------
>>   arch/powerpc/kvm/book3s_64_mmu_radix.c       | 12 ++------
>>   2 files changed, 24 insertions(+), 18 deletions(-)
>>
>> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> index 581f91be9dd4..f6d1ac8b832e 100644
>> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> @@ -897,6 +897,12 @@ static inline int pud_present(pud_t pud)
>>       return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
>>   }
>>   +#define pud_large    pud_large
>> +static inline int pud_large(pud_t pud)
>> +{
>> +    return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
>> +}
>> +
>>   extern struct page *pud_page(pud_t pud);
>>   extern struct page *pmd_page(pmd_t pmd);
>>   static inline pte_t pud_pte(pud_t pud)
>> @@ -940,6 +946,12 @@ static inline int pgd_present(pgd_t pgd)
>>       return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>>   }
>>   +#define pgd_large    pgd_large
>> +static inline int pgd_large(pgd_t pgd)
>> +{
>> +    return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
>> +}
>> +
>>   static inline pte_t pgd_pte(pgd_t pgd)
>>   {
>>       return __pte_raw(pgd_raw(pgd));
>> @@ -1093,6 +1105,15 @@ static inline bool pmd_access_permitted(pmd_t
>> pmd, bool write)
>>       return pte_access_permitted(pmd_pte(pmd), write);
>>   }
>>   +#define pmd_large    pmd_large
>> +/*
>> + * returns true for pmd migration entries, THP, devmap, hugetlb
>> + */
>> +static inline int pmd_large(pmd_t pmd)
>> +{
>> +    return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
>> +}
>> +
>>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>   extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
>>   extern pmd_t mk_pmd(struct page *page, pgprot_t pgprot);
>> @@ -1119,15 +1140,6 @@ pmd_hugepage_update(struct mm_struct *mm,
>> unsigned long addr, pmd_t *pmdp,
>>       return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
>>   }
>>   -/*
>> - * returns true for pmd migration entries, THP, devmap, hugetlb
>> - * But compile time dependent on THP config
>> - */
>> -static inline int pmd_large(pmd_t pmd)
>> -{
>> -    return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
>> -}
>> -
>>   static inline pmd_t pmd_mknotpresent(pmd_t pmd)
>>   {
>>       return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
>> diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c
>> b/arch/powerpc/kvm/book3s_64_mmu_radix.c
>> index f55ef071883f..1b57b4e3f819 100644
>> --- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
>> +++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
>> @@ -363,12 +363,6 @@ static void kvmppc_pte_free(pte_t *ptep)
>>       kmem_cache_free(kvm_pte_cache, ptep);
>>   }
>>   -/* Like pmd_huge() and pmd_large(), but works regardless of config
>> options */
>> -static inline int pmd_is_leaf(pmd_t pmd)
>> -{
>> -    return !!(pmd_val(pmd) & _PAGE_PTE);
>> -}
>> -
>>   static pmd_t *kvmppc_pmd_alloc(void)
>>   {
>>       return kmem_cache_alloc(kvm_pmd_cache, GFP_KERNEL);
>> @@ -460,7 +454,7 @@ static void kvmppc_unmap_free_pmd(struct kvm *kvm,
>> pmd_t *pmd, bool full,
>>       for (im = 0; im < PTRS_PER_PMD; ++im, ++p) {
>>           if (!pmd_present(*p))
>>               continue;
>> -        if (pmd_is_leaf(*p)) {
>> +        if (pmd_large(*p)) {
>>               if (full) {
>>                   pmd_clear(p);
>>               } else {
>> @@ -593,7 +587,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t
>> *pgtable, pte_t pte,
>>       else if (level <= 1)
>>           new_pmd = kvmppc_pmd_alloc();
>>   -    if (level == 0 && !(pmd && pmd_present(*pmd) &&
>> !pmd_is_leaf(*pmd)))
>> +    if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_large(*pmd)))
>>           new_ptep = kvmppc_pte_alloc();
>>         /* Check if we might have been invalidated; let the guest
>> retry if so */
>> @@ -662,7 +656,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t
>> *pgtable, pte_t pte,
>>           new_pmd = NULL;
>>       }
>>       pmd = pmd_offset(pud, gpa);
>> -    if (pmd_is_leaf(*pmd)) {
>> +    if (pmd_large(*pmd)) {
>>           unsigned long lgpa = gpa & PMD_MASK;
>>             /* Check if we raced and someone else has set the same
>> thing */
>>
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

