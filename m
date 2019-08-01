Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78080C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:40:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20D96206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:40:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20D96206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C02128E0005; Thu,  1 Aug 2019 02:40:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8BE18E0001; Thu,  1 Aug 2019 02:40:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2BD18E0005; Thu,  1 Aug 2019 02:40:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51A628E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:40:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n3so44048392edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:40:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DvU+QCyPDRHzWl2t3RU2ZOsI0Akp1PvaRHyP4+ebKxE=;
        b=Ue/t2UrWEDlCnU2kzWgkX493SDUQRgEyu33MXoYTR9Bn0sAspT6EBF9SkguGrmAgIS
         NCyOeEzWsUfiu73jET1C6hUZ+54VGkA4Bh8/mOREv3VG/+ltSEzSVLwqkZ6VoXrnvHAz
         ye2b9CNFSbhHrj39/Fuij3XelZh75A6V0x9+pXdRKc8MvJP2ARtR9o6NkH8knQT+d38j
         e2J/sQpR/1FPRF4xN9WFztfQGuxPRDgg0ROnM5NRkeu5QJvwpc6rIRA68LMTrqZL/9jS
         QhPsbPNAZb+iSGMbm/OgUkawXXb1jDq4ISUyi2KUbOeazQUeSaDUZeZINY6KmbkHPzGv
         sehg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU6begp2VXPC2L3eC6Hd4y5w4rNAuv75V38fYn4VixiGw3UzLMy
	ahJhY25RgVrPFVz2u3p8Qx+bqzIJURbJsQVfTm6sEs59Wp9v1ZJLqWFZz/zYlInKA4OYnLZ8A4w
	B4oZSoa6bRfp2iqJsb9Pcndlz8GeQuvMUA2Ghc23Ug0XMOpJVz8CgxZ+Oi58LUSBHkQ==
X-Received: by 2002:a05:6402:1612:: with SMTP id f18mr110916393edv.231.1564641645888;
        Wed, 31 Jul 2019 23:40:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxtXW7BnHxMgVtliuLiXYq3tFWghfogNlMCreQch5uO7syYeqiZdUub7XosxhE8PB8X5f7
X-Received: by 2002:a05:6402:1612:: with SMTP id f18mr110916355edv.231.1564641645122;
        Wed, 31 Jul 2019 23:40:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564641645; cv=none;
        d=google.com; s=arc-20160816;
        b=MkH/5E4BGeork0rO6/J5kza3lM/VC60EMpbMfquxhzpw+b79qsTCkwSnUjpCS9585m
         DB/Db+/WefLUih+HKbSgxyt1JTvVlaVDaeeWgnlTAzSlz99lB2BjmXTkI3QpzA0+x7kB
         hog6n4AmCtIMWvQzEWXDHG88lms55a6LzSWiPZlNY4ZdMwT2hjmbxPBpjzDFggl9Q56y
         p2Acb5Xe0JaMvyuE711EW48n/hS0GfeL4HCJzTOBfF4IxTrmpRMLc7aWdLtfQJEBu0VV
         h87MSV2vsyK7Re/CcN8msO6gYWE5iKPRHtreAiK9LQ4CkJUUoyFazaelZKXLLHCncN74
         Pv5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DvU+QCyPDRHzWl2t3RU2ZOsI0Akp1PvaRHyP4+ebKxE=;
        b=Byu11h1N1WrrllzEomufN+p7NjuBVoR+0jsOuVcBxCZ8BClPARrLoFBU5r6s/oC1+w
         u4iDvsSpu1Ucm6ziKZu+ZAYq/pPpP54qKKhP7qYlRJPfPhCuF202WQYT+B/QsJg71nYg
         35v/osV/C5Ial5PzLFVJszATQL77Q6kv5QA15zMo6MnU6k9iIghDaSodUOhH5SRcjjLj
         C41fhOnkaqV/s4gEuAcC+mU7CHXjUVzZWWy/rbxUe2vUdyYP2dPr33JTAAzWGxxMndUJ
         L9HuHGfVdYnVu/DrwiE8cLrazTpcUqz47lDV7YuJx+EIRaZdF8WXSXCBkv+W/2CY0a/t
         COdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f6si18745589eja.338.2019.07.31.23.40.44
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 23:40:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AF3BA337;
	Wed, 31 Jul 2019 23:40:43 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 84E463F694;
	Wed, 31 Jul 2019 23:42:33 -0700 (PDT)
Subject: Re: [PATCH v9 12/21] mm: pagewalk: Allow walking without vma
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-13-steven.price@arm.com>
 <7fc50563-7d5d-7270-5a6a-63769e9c335a@arm.com>
 <5aff70f7-67a5-c7e8-5fec-8182dea0da0c@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b43b68c5-8245-52cc-31b8-613dc299a469@arm.com>
Date: Thu, 1 Aug 2019 12:11:05 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <5aff70f7-67a5-c7e8-5fec-8182dea0da0c@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/29/2019 05:59 PM, Steven Price wrote:
> On 28/07/2019 15:20, Anshuman Khandual wrote:
>>
>>
>> On 07/22/2019 09:12 PM, Steven Price wrote:
>>> Since 48684a65b4e3: "mm: pagewalk: fix misbehavior of walk_page_range
>>> for vma(VM_PFNMAP)", page_table_walk() will report any kernel area as
>>> a hole, because it lacks a vma.
>>>
>>> This means each arch has re-implemented page table walking when needed,
>>> for example in the per-arch ptdump walker.
>>>
>>> Remove the requirement to have a vma except when trying to split huge
>>> pages.
>>>
>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>> ---
>>>  mm/pagewalk.c | 25 +++++++++++++++++--------
>>>  1 file changed, 17 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
>>> index 98373a9f88b8..1cbef99e9258 100644
>>> --- a/mm/pagewalk.c
>>> +++ b/mm/pagewalk.c
>>> @@ -36,7 +36,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>>>  	do {
>>>  again:
>>>  		next = pmd_addr_end(addr, end);
>>> -		if (pmd_none(*pmd) || !walk->vma) {
>>> +		if (pmd_none(*pmd)) {
>>>  			if (walk->pte_hole)
>>>  				err = walk->pte_hole(addr, next, walk);
>>>  			if (err)
>>> @@ -59,9 +59,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>>>  		if (!walk->pte_entry)
>>>  			continue;
>>>  
>>> -		split_huge_pmd(walk->vma, pmd, addr);
>>> -		if (pmd_trans_unstable(pmd))
>>> -			goto again;
>>> +		if (walk->vma) {
>>> +			split_huge_pmd(walk->vma, pmd, addr);
>>
>> Check for a PMD THP entry before attempting to split it ?
> 
> split_huge_pmd does the check for us:
>> #define split_huge_pmd(__vma, __pmd, __address)				\
>> 	do {								\
>> 		pmd_t *____pmd = (__pmd);				\
>> 		if (is_swap_pmd(*____pmd) || pmd_trans_huge(*____pmd)	\
>> 					|| pmd_devmap(*____pmd))	\
>> 			__split_huge_pmd(__vma, __pmd, __address,	\
>> 						false, NULL);		\
>> 	}  while (0)
> 
> And this isn't a change from the previous code - only that the entry is
> no longer split when walk->vma==NULL.

Does it make sense to name walk->vma check to differentiate between user
and kernel page tables. IMHO that will help make things clear and explicit
during page table walk.

> 
>>> +			if (pmd_trans_unstable(pmd))
>>> +				goto again;
>>> +		} else if (pmd_leaf(*pmd)) {
>>> +			continue;
>>> +		}
>>> +
>>>  		err = walk_pte_range(pmd, addr, next, walk);
>>>  		if (err)
>>>  			break;
>>> @@ -81,7 +86,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>>>  	do {
>>>   again:
>>>  		next = pud_addr_end(addr, end);
>>> -		if (pud_none(*pud) || !walk->vma) {
>>> +		if (pud_none(*pud)) {
>>>  			if (walk->pte_hole)
>>>  				err = walk->pte_hole(addr, next, walk);
>>>  			if (err)
>>> @@ -95,9 +100,13 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>>>  				break;
>>>  		}
>>>  
>>> -		split_huge_pud(walk->vma, pud, addr);
>>> -		if (pud_none(*pud))
>>> -			goto again;
>>> +		if (walk->vma) {
>>> +			split_huge_pud(walk->vma, pud, addr);
>>
>> Check for a PUD THP entry before attempting to split it ?
> 
> Same as above.
> 
>>> +			if (pud_none(*pud))
>>> +				goto again;
>>> +		} else if (pud_leaf(*pud)) {
>>> +			continue;
>>> +		}
>>
>> This is bit cryptic. walk->vma check should be inside a helper is_user_page_table()
>> or similar to make things clear. p4d_leaf() check missing in walk_p4d_range() for
>> kernel page table walk ? Wondering if p?d_leaf() test should be moved earlier while
>> calling p?d_entry() for kernel page table walk.
> 
> I wasn't sure if it was worth putting p4d_leaf() and pgd_leaf() checks
> in (yet). No architecture that I know of uses such large pages.

Just to be complete it does make sense to add the remaining possible leaf
entry checks but will leave it upto you.

> 
> I'm not sure what you mean by moving the p?d_leaf() test earlier? Can
> you explain with an example?

In case its a kernel p?d_leaf() entry, then there is nothing to be done
after calling respective walk->p?d_entry() functions. Hence this check
should not complement user page table check (walk->vma) later in the
function but instead be checked right after walk->p?d_entry(). But its
not a big deal I guess.

