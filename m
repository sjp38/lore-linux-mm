Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BD53C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31A8D22ADB
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:04:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31A8D22ADB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0F196B0003; Wed, 24 Jul 2019 09:04:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC0C76B0005; Wed, 24 Jul 2019 09:04:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D5C96B0006; Wed, 24 Jul 2019 09:04:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCE06B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:04:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so30144544edx.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:04:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=U5uKFvCvqdS6xb4mC84vOGAE2zJGUM2OcXjCkR+r6dM=;
        b=qqUQ35/LROaJGsomBrbOWXBMm/+MKXASShQOGf+NtefwYvAiJsymK6HpMdGIMnIHkS
         +HGY2H5VsRY1UB5o+sEB7m/jrT1DWPXrN5p2ia3MGBd3scgrD/hgSDZafGoymT0XZcow
         RUDqblu69xwBWjlmlZOx+gpKjl2C14mbVr5gLt40cVhPdR6kLmeZ0uXdGpJA9JwxUmLX
         qjSfrcOhawx4gmkl8pEth7TWkZLLr9qOe+D4wpcyTBg7DO3WE7yXU8ky3smJGaVFUTyz
         HwPx/S0a/G5avUC7dC8QiOlsP4EkVb3ysQljqXek3dSgTdBv2HQL0r5xwZnUAykD9EjW
         Jxug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWtbJNJ3hQiqTTYB4grxtLaaKP/j+GTDgORvpIcQn14NGiRrpu4
	x55QkHYyqoiDeU9kti6B2g49tOuz84qg1Dy+Af4K9A7MM/nGHWZZ0QDlRdnB2wf1NWJ4Y2fFLhL
	fYY0qEswB/FSbeEsJEaKIJH0/FD0quSh90oPN2+hrw7P41ZQAMMxJoVMVTcWCqO1rtw==
X-Received: by 2002:a17:906:8591:: with SMTP id v17mr62306832ejx.244.1563973445860;
        Wed, 24 Jul 2019 06:04:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5ay7/0Wmi+I+2tpXY4Tt0NLB6ic/JuPWseQHZFBO7HmWSZ+sX+ME22+ZY7Md3sw4jfTQI
X-Received: by 2002:a17:906:8591:: with SMTP id v17mr62306732ejx.244.1563973444837;
        Wed, 24 Jul 2019 06:04:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563973444; cv=none;
        d=google.com; s=arc-20160816;
        b=d9xc+eD2glQqtyAibUsDmlc6AN7t8QjU8bNJO7I+dMfu7rJ4Rmj41f1jTcXMRNTDKS
         FTPZ3fgJI1hPjBKANg/RaegNN15XidyPDpWQ8QSnU/EqWE49vfFbu3CJwR361cHCMtJ+
         f9/b/a9ExxwVVwX9/dfPcSE51q9aMC/84SkGy+KOX5UQg9py2dIqglf2IRpPjWkU6YwV
         YjyxWLAxzcOxdKd5imYA3SQHtZWEoHUNXFXK9gKI/fw6TWhajwhGV0BbkunQpqAlCtOs
         QuyKUHGPTieMoDbAEzhEDW8YVqXy0LydM9E1tY5V+xHCD5uOK5EfM4uwokugSPATsVs2
         DGpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=U5uKFvCvqdS6xb4mC84vOGAE2zJGUM2OcXjCkR+r6dM=;
        b=w+/QyCKxlnTZthdUXgEZmqgcZAe+2wgojmpP9nGeEWsSw3uKh2sFpNNrDaOpO9sGlN
         OnzubkUeWa0ijpztHcqZedqk9DNfkM/7qD1qnBA2BG2v0okB6HzJFwa0KZVXWYxLn1wh
         YqvmaccBY09JvfuOl7DLgyyySbCSLwa+8srzJydY4G+zabyw1caZtc0G9s1k9w1GrqNM
         R8TZOB+H/pwcDOe5WQ+mjBWNcPaKP0R2OfiGi+QogrY3mu+paqe9ZWqg2kgcUga57dx0
         irRbJy6SUeOKT3MbMVI1MZCQ6X5XKeldrRxauFM+F3RtLN5Nqiwzy09paRpGrpWlG0da
         /tmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k12si8227440edd.448.2019.07.24.06.04.03
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 06:04:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 29A9128;
	Wed, 24 Jul 2019 06:04:03 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1FC383F71A;
	Wed, 24 Jul 2019 06:04:00 -0700 (PDT)
Subject: Re: [PATCH v9 04/21] mips: mm: Add p?d_leaf() definitions
To: Paul Burton <paul.burton@mips.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
 <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>,
 Will Deacon <will@kernel.org>, "Liang, Kan" <kan.liang@linux.intel.com>,
 "x86@kernel.org" <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>,
 James Hogan <jhogan@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Ralf Baechle <ralf@linux-mips.org>, James Morse <james.morse@arm.com>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-5-steven.price@arm.com>
 <20190722214722.wdlj6a3der3r2oro@pburton-laptop>
From: Steven Price <steven.price@arm.com>
Message-ID: <85b20d93-bb60-b9e2-ea6a-92ca6f90abc6@arm.com>
Date: Wed, 24 Jul 2019 14:03:58 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722214722.wdlj6a3der3r2oro@pburton-laptop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22/07/2019 22:47, Paul Burton wrote:
> Hi Steven,
> 
> On Mon, Jul 22, 2019 at 04:41:53PM +0100, Steven Price wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_leaf() functions/macros.
>>
>> For mips, we only support large pages on 64 bit.
> 
> That ceases to be true with commit 35476311e529 ("MIPS: Add partial
> 32-bit huge page support") in mips-next, so I think it may be best to
> move the definition to asm/pgtable.h so that both 32b & 64b kernels can
> pick it up.

Thanks for pointing that out. I'll move the definitions as you suggest.

Steve

> Thanks,
>     Paul
> 
>> For 64 bit if _PAGE_HUGE is defined we can simply look for it. When not
>> defined we can be confident that there are no leaf pages in existence
>> and fall back on the generic implementation (added in a later patch)
>> which returns 0.
>>
>> CC: Ralf Baechle <ralf@linux-mips.org>
>> CC: Paul Burton <paul.burton@mips.com>
>> CC: James Hogan <jhogan@kernel.org>
>> CC: linux-mips@vger.kernel.org
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  arch/mips/include/asm/pgtable-64.h | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
>> index 93a9dce31f25..2bdbf8652b5f 100644
>> --- a/arch/mips/include/asm/pgtable-64.h
>> +++ b/arch/mips/include/asm/pgtable-64.h
>> @@ -273,6 +273,10 @@ static inline int pmd_present(pmd_t pmd)
>>  	return pmd_val(pmd) != (unsigned long) invalid_pte_table;
>>  }
>>  
>> +#ifdef _PAGE_HUGE
>> +#define pmd_leaf(pmd)	((pmd_val(pmd) & _PAGE_HUGE) != 0)
>> +#endif
>> +
>>  static inline void pmd_clear(pmd_t *pmdp)
>>  {
>>  	pmd_val(*pmdp) = ((unsigned long) invalid_pte_table);
>> @@ -297,6 +301,10 @@ static inline int pud_present(pud_t pud)
>>  	return pud_val(pud) != (unsigned long) invalid_pmd_table;
>>  }
>>  
>> +#ifdef _PAGE_HUGE
>> +#define pud_leaf(pud)	((pud_val(pud) & _PAGE_HUGE) != 0)
>> +#endif
>> +
>>  static inline void pud_clear(pud_t *pudp)
>>  {
>>  	pud_val(*pudp) = ((unsigned long) invalid_pmd_table);
>> -- 
>> 2.20.1
>>
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

