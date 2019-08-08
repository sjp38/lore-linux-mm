Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01BADC32754
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C26A52184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:59:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C26A52184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 464506B0003; Thu,  8 Aug 2019 02:59:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4140F6B0006; Thu,  8 Aug 2019 02:59:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DC826B0007; Thu,  8 Aug 2019 02:59:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D16826B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:59:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y23so1196433edo.13
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:59:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GR+ypBp5ONQHrTrfwOgJfuqY+wie+rfR9gnQqQu2w1o=;
        b=FBeqqMJCTNqx9VBfK9Ftr6zvP2/4xvCXPrCsSPC1C463F5bWDl4asjk8j5lQWOuaCV
         mTw+uyy51wem63PsCG5sotQAexAarpgkhBj/UltNazBhdAhlneMs/Qivb4hTMj0rson9
         R3AFNwmq2ucmBcFOwUxBm70FiHIBZKQK7FdfXrBz51yftw/VZJnum9lQyd5fPGpdsjJe
         ix4vvo39KmYbPk+ZAz4dUIGpHTQ0sqtb3zDUSlPh+NwagKXKTdua3lBp0Zvs4/VQQ1ay
         V4/nVPgsHIZ1qofpfhaAHWuYgC6v1ZFjwZ95OgnKRaFgXQAGGcZY0xLNuCcKFWb5CrIM
         Bbng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUS6aUZ2qUYZHZBZyEcc3ryqvYDu0lqxehubgQPZrRdu0dW8Mcr
	3EbqcnNcVCxIBzU5moK3C1Dc4tJuizrSoN9WdFuU6nk+9W7kudIUjvXPTSQpYSk6436pVzPvx6M
	r8dMWV3N2t6v3eOSy4dvaO3oTbcDo8bAXDaMyR/8jJ1nfHwsssZcjSEwfLQaOzaqwQg==
X-Received: by 2002:a17:907:2130:: with SMTP id qo16mr11954680ejb.235.1565247555391;
        Wed, 07 Aug 2019 23:59:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6sdOMo/WDTWAJ6tLl651TI4l5QBJ5PE0AHOCdoujkdRjdkDtFZURE4zzrWW/NkMWSBuGf
X-Received: by 2002:a17:907:2130:: with SMTP id qo16mr11954636ejb.235.1565247554470;
        Wed, 07 Aug 2019 23:59:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565247554; cv=none;
        d=google.com; s=arc-20160816;
        b=MbwxwVoUcMIRenFJj9slDfPRF6wv7pXVB1VQRdWF0/4lnjHOsE6fgTXZ6u+zVsTT88
         tJPdT8O6r4glpuCZ7yB7q5N14q+nq3xkfeguHOzTonh5TX5/A1kq6jCpe2QBnpgl2/sG
         2UPt7D53Q6ux8UwH0sKSq80EDxl8+b52qjoftehy5ajERaQmf676GMoOpm2dRxOZeOoP
         a5dj+RWgdgobDG6pbzsJ7z+PdvGVGa/9iFs5tq3rpdBpTFW15ZsIJD2V2WoZPC8r+SZc
         2poH31xt9XAQT6UK8f1LHpieLN1eN4hYdVfBt4/wtAQe6hVfDw4qFJ+kMhhFEPONpsKV
         0PZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=GR+ypBp5ONQHrTrfwOgJfuqY+wie+rfR9gnQqQu2w1o=;
        b=TpvYejij33lDD/C3LDgurWCoBfLCNIxg3dTY6sDUhQe+3UQw9t4pRquaANhwFUUdWG
         rKF0YPxt9wmzAaaZkIaW1ZsxJQ2JYSPFWTpuwNGNFFoK9zHjuv4XnsEmvSz/g7GN2Njl
         N/gjCrm4mxNbsorTYwkhq+mX5cfIvstvA7MrmtgCxuobI0QXS9ACfCbnPMu7KNZZkL/y
         yn00pzaMccC0adBqKteDBcnLtqXrhSAHpLPh1Bmx6WQVj3ovYuFHUAEKzRTb97Lb5nyZ
         1tFaomG5OFMhTXtMrWNcpFXO+j4++dhNeMoX7KazYxI3WDCSqkZbk9TK73QeVqOEY0+H
         w2hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id s50si40057329edb.270.2019.08.07.23.59.14
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 23:59:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1E449337;
	Wed,  7 Aug 2019 23:59:13 -0700 (PDT)
Received: from [10.163.1.243] (unknown [10.163.1.243])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6A1CF3F706;
	Thu,  8 Aug 2019 00:01:13 -0700 (PDT)
Subject: Re: [PATCH] arm64: mm: add missing PTE_SPECIAL in pte_mkdevmap on
 arm64
To: "Justin He (Arm Technology China)" <Justin.He@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will@kernel.org>,
 Mark Rutland <Mark.Rutland@arm.com>, James Morse <James.Morse@arm.com>
Cc: Christoffer Dall <Christoffer.Dall@arm.com>,
 Punit Agrawal <punitagrawal@gmail.com>, Qian Cai <cai@lca.pw>,
 Jun Yao <yaojun8558363@gmail.com>, Alex Van Brunt <avanbrunt@nvidia.com>,
 Robin Murphy <Robin.Murphy@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Dan Williams <dan.j.williams@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>,
 Christoph Hellwig <hch@lst.de>
References: <20190807045851.10772-1-justin.he@arm.com>
 <ce0be561-117c-ef94-6a26-f88c3ba21096@arm.com>
 <DB7PR08MB30823791749E5B083AF167B5F7D70@DB7PR08MB3082.eurprd08.prod.outlook.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7c950e09-bc34-fa19-8889-598832c97b44@arm.com>
Date: Thu, 8 Aug 2019 12:28:58 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <DB7PR08MB30823791749E5B083AF167B5F7D70@DB7PR08MB3082.eurprd08.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 08/08/2019 11:50 AM, Justin He (Arm Technology China) wrote:
> Hi Anshuman
> Thanks for the comments, please see my comments below
> 
>> -----Original Message-----
>> From: Anshuman Khandual <anshuman.khandual@arm.com>
>> Sent: 2019年8月8日 13:19
>> To: Justin He (Arm Technology China) <Justin.He@arm.com>; Catalin
>> Marinas <Catalin.Marinas@arm.com>; Will Deacon <will@kernel.org>;
>> Mark Rutland <Mark.Rutland@arm.com>; James Morse
>> <James.Morse@arm.com>
>> Cc: Christoffer Dall <Christoffer.Dall@arm.com>; Punit Agrawal
>> <punitagrawal@gmail.com>; Qian Cai <cai@lca.pw>; Jun Yao
>> <yaojun8558363@gmail.com>; Alex Van Brunt <avanbrunt@nvidia.com>;
>> Robin Murphy <Robin.Murphy@arm.com>; Thomas Gleixner
>> <tglx@linutronix.de>; linux-arm-kernel@lists.infradead.org; linux-
>> kernel@vger.kernel.org
>> Subject: Re: [PATCH] arm64: mm: add missing PTE_SPECIAL in
>> pte_mkdevmap on arm64
>>
> [...]
>>> diff --git a/arch/arm64/include/asm/pgtable.h
>> b/arch/arm64/include/asm/pgtable.h
>>> index 5fdcfe237338..e09760ece844 100644
>>> --- a/arch/arm64/include/asm/pgtable.h
>>> +++ b/arch/arm64/include/asm/pgtable.h
>>> @@ -209,7 +209,7 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
>>>
>>>  static inline pte_t pte_mkdevmap(pte_t pte)
>>>  {
>>> -	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
>>> +	return set_pte_bit(pte, __pgprot(PTE_DEVMAP | PTE_SPECIAL));
>>>  }
>>>
>>>  static inline void set_pte(pte_t *ptep, pte_t pte)
>>> @@ -396,7 +396,10 @@ static inline int pmd_protnone(pmd_t pmd)
>>>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>>  #define pmd_devmap(pmd)		pte_devmap(pmd_pte(pmd))
>>>  #endif
>>> -#define pmd_mkdevmap(pmd)
>> 	pte_pmd(pte_mkdevmap(pmd_pte(pmd)))
>>> +static inline pmd_t pmd_mkdevmap(pmd_t pmd)
>>> +{
>>> +	return pte_pmd(set_pte_bit(pmd_pte(pmd),
>> __pgprot(PTE_DEVMAP)));
>>> +}
>>
>> Though I could see other platforms like powerpc and x86 following same
>> approach (DEVMAP + SPECIAL) for pte so that it checks positive for
>> pte_special() but then just DEVMAP for pmd which could never have a
>> pmd_special(). But a more fundamental question is - why should a devmap
>> be a special pte as well ?
> 
> IIUC, special pte bit make things handling easier compare with those arches which
> have no special bit. The memory codes will regard devmap page as a special one 
> compared with normal page.

For that we have PTE_DEVMAP on arm64 which differentiates device memory
entries from others and it should not again need PTE_SPECIAL as well for
that. We set both bits while creating the entries with pte_mkdevmap()
and check just one bit PTE_DEVMAP with pte_devmap(). Problem is it will
also test positive for pte_special() and risks being identified as one.

> Devmap page structure can be stored in ram/pmem/none.

That is altogether a different aspect which is handled with vmem_altmap
during hotplug and nothing to do with how device memory is mapped in the
page table. I am not sure about "none" though. IIUC unlike traditional
device pfn all ZONE_DEVICE memory will have struct page backing either
on system RAM or in the device memory itself.

> 
>>
>> Also in vm_normal_page() why cannot it tests for pte_devmap() before it
>> starts looking for CONFIG_ARCH_HAS_PTE_SPECIAL. Is this the only path
>> for
> 
> AFAICT, yes, but it changes to much besides arm codes. 😊

If this is the only path for which all platforms have to set PTE_SPECIAL
in their device mapping, then it should just be fixed in vm_normal_page().

> 
>> which we need to set SPECIAL bit on a devmap pte or there are other paths
>> where this semantics is assumed ?
> 
> No idea

Probably something to be asked in the mm community.

1. Why pte_mkdevmap() should set SPECIAL bit for a positive pte_special()
   check. Why the same mapping be identified as pte_devmap() as well as
   pte_special().

2. Can pte_devmap() and pte_special() re-ordering at vm_normal_page() will
   remove this dependency or there are other commons MM paths which assume
   this behavior ?

+ linux-mm@kvack.org <linux-mm@kvack.org>
+ Dan Williams <dan.j.williams@intel.com>
+ Jérôme Glisse <jglisse@redhat.com>
+ Logan Gunthorpe <logang@deltatee.com>
+ Christoph Hellwig <hch@lst.de>

