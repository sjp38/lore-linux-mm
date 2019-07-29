Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3B86C76193
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:30:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B129214AE
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:30:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B129214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCF688E0003; Mon, 29 Jul 2019 08:30:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C57D08E0002; Mon, 29 Jul 2019 08:30:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF87E8E0003; Mon, 29 Jul 2019 08:30:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EAF98E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:30:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so38187233eda.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:30:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VhZ0weODvxVPuYMMMd5+/UN55Ksi6jDNOcYU1PMKVws=;
        b=BVb7tnTdY7NXpniQeCq2AYgeY5Y8/wXF7KYld4HjWSXuUAJcnIs9DAKKL1lvTBJWLH
         NnRAzqvfBgnwowsL88lEwAYK4shDzYW0/ZIMJw2Xy608f9M3Qcsdx3PS3O2f1Y+2/yM6
         Wl9hlZ4ZDxbuJZ6dl3HF77gYY5NZKiHhBvFQv6oH+9DTHwOkCcapE25te5584lGPK0+t
         ZwMBv95hwQoUvuSVFvQsAUngLpOmNfGo2qvi5e7vNeZCIAcL/9UJ5BkOa2BtIYHp002c
         itL09i560rGPLwavhRNOLnPMOFBW70MTnjVwma54iq6OqGD3smFEA9Ga4hKl3Ao2C8QQ
         bgyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUMfysRrvaxIIEzYovZnXQqAjz8vIav4kselyBwO4xZa5bfBh5S
	k9qQoVDzvsAk++GYWlb3cMCjfx88FJFjuvlpgnkLyOo3nXIazomkJbyf+osztl0ucQnFD6FJQQx
	wLp0aYsbjosJrpKKsKz/eRQeST17vJ2IcSgrH1LW9h3nEKStyBeM+dDFMmM5dGyaXhA==
X-Received: by 2002:a17:906:fac7:: with SMTP id lu7mr50258797ejb.109.1564403409925;
        Mon, 29 Jul 2019 05:30:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4IwKit+3ulZLvXo9U6rEI1F5luUvPc73GUw8s9wbZyBEEEDfSpI2IJ5RZRrd6btkRMiwG
X-Received: by 2002:a17:906:fac7:: with SMTP id lu7mr50258735ejb.109.1564403409058;
        Mon, 29 Jul 2019 05:30:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564403409; cv=none;
        d=google.com; s=arc-20160816;
        b=BiMoOCnySZ9tjEVr+ch+YZl5gCp3hc1iWYmQx1LL0zITsdNczopcLoZ8VlR/m3C0my
         iT0SG9uoXnJ7tMEicWMQ4BFcqFvM3Rec4982h2U0XjrWoLRcP97Soh0tuMdrxL22JACb
         6424o0Gj4prJ6o2xziSLsqpxJjY3BYH+3sNtJJHmnf/JmQBGj3G2fBys0NOm0h9rnLwk
         dFfUJmrmJowKGjlS2at0YRYej7CehT81pFQyktGi+hf3tt6Acick2ju2n9j7QgJemyX5
         uKuqCv0RZDEV83msSoPJdHg/xhQr/E0d0lz3dbi3KaBEuhu8XLJWwzS2fevkMRdjKUT5
         wyVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VhZ0weODvxVPuYMMMd5+/UN55Ksi6jDNOcYU1PMKVws=;
        b=ZOMsMa3J/M+zeVxDjJkqEf+Hf9/LzDXRj1Z0uGE/sEhxAXXa3Dy825Ht9259WKgX2e
         DO/jan1DreKaHOrfKWCd0VMxvrL3vnwksj3oYa1vRSoCd9sAkDMd6yi4Z0tHxab83ypl
         gEBtEv3av5rTl9AAuWcdzuYuwMHvapOHzaWtqGYXBgA4q9XpYHlw0SlK3Odfm/5q9W+V
         xhHNvgpeY3pt7t/HGPsm0/MGDCS48rMvg9tg1Z0c0dOWxU+vXvbiQc88bH4OBoiBKrB4
         XM96wn3HKDD8IETxps/IKVGasTIhplmCGKRQldfZVkX4uoQBGoEjoo/Wv1f0TQNHh1oI
         E0Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id ec8si14475126ejb.184.2019.07.29.05.30.07
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 05:30:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1D1DA28;
	Mon, 29 Jul 2019 05:30:07 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 75AB43F575;
	Mon, 29 Jul 2019 05:29:59 -0700 (PDT)
Subject: Re: [PATCH v9 12/21] mm: pagewalk: Allow walking without vma
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
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
From: Steven Price <steven.price@arm.com>
Message-ID: <5aff70f7-67a5-c7e8-5fec-8182dea0da0c@arm.com>
Date: Mon, 29 Jul 2019 13:29:58 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <7fc50563-7d5d-7270-5a6a-63769e9c335a@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/07/2019 15:20, Anshuman Khandual wrote:
> 
> 
> On 07/22/2019 09:12 PM, Steven Price wrote:
>> Since 48684a65b4e3: "mm: pagewalk: fix misbehavior of walk_page_range
>> for vma(VM_PFNMAP)", page_table_walk() will report any kernel area as
>> a hole, because it lacks a vma.
>>
>> This means each arch has re-implemented page table walking when needed,
>> for example in the per-arch ptdump walker.
>>
>> Remove the requirement to have a vma except when trying to split huge
>> pages.
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  mm/pagewalk.c | 25 +++++++++++++++++--------
>>  1 file changed, 17 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
>> index 98373a9f88b8..1cbef99e9258 100644
>> --- a/mm/pagewalk.c
>> +++ b/mm/pagewalk.c
>> @@ -36,7 +36,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>>  	do {
>>  again:
>>  		next = pmd_addr_end(addr, end);
>> -		if (pmd_none(*pmd) || !walk->vma) {
>> +		if (pmd_none(*pmd)) {
>>  			if (walk->pte_hole)
>>  				err = walk->pte_hole(addr, next, walk);
>>  			if (err)
>> @@ -59,9 +59,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>>  		if (!walk->pte_entry)
>>  			continue;
>>  
>> -		split_huge_pmd(walk->vma, pmd, addr);
>> -		if (pmd_trans_unstable(pmd))
>> -			goto again;
>> +		if (walk->vma) {
>> +			split_huge_pmd(walk->vma, pmd, addr);
> 
> Check for a PMD THP entry before attempting to split it ?

split_huge_pmd does the check for us:
> #define split_huge_pmd(__vma, __pmd, __address)				\
> 	do {								\
> 		pmd_t *____pmd = (__pmd);				\
> 		if (is_swap_pmd(*____pmd) || pmd_trans_huge(*____pmd)	\
> 					|| pmd_devmap(*____pmd))	\
> 			__split_huge_pmd(__vma, __pmd, __address,	\
> 						false, NULL);		\
> 	}  while (0)

And this isn't a change from the previous code - only that the entry is
no longer split when walk->vma==NULL.

>> +			if (pmd_trans_unstable(pmd))
>> +				goto again;
>> +		} else if (pmd_leaf(*pmd)) {
>> +			continue;
>> +		}
>> +
>>  		err = walk_pte_range(pmd, addr, next, walk);
>>  		if (err)
>>  			break;
>> @@ -81,7 +86,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>>  	do {
>>   again:
>>  		next = pud_addr_end(addr, end);
>> -		if (pud_none(*pud) || !walk->vma) {
>> +		if (pud_none(*pud)) {
>>  			if (walk->pte_hole)
>>  				err = walk->pte_hole(addr, next, walk);
>>  			if (err)
>> @@ -95,9 +100,13 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>>  				break;
>>  		}
>>  
>> -		split_huge_pud(walk->vma, pud, addr);
>> -		if (pud_none(*pud))
>> -			goto again;
>> +		if (walk->vma) {
>> +			split_huge_pud(walk->vma, pud, addr);
> 
> Check for a PUD THP entry before attempting to split it ?

Same as above.

>> +			if (pud_none(*pud))
>> +				goto again;
>> +		} else if (pud_leaf(*pud)) {
>> +			continue;
>> +		}
> 
> This is bit cryptic. walk->vma check should be inside a helper is_user_page_table()
> or similar to make things clear. p4d_leaf() check missing in walk_p4d_range() for
> kernel page table walk ? Wondering if p?d_leaf() test should be moved earlier while
> calling p?d_entry() for kernel page table walk.

I wasn't sure if it was worth putting p4d_leaf() and pgd_leaf() checks
in (yet). No architecture that I know of uses such large pages.

I'm not sure what you mean by moving the p?d_leaf() test earlier? Can
you explain with an example?

Thanks,

Steve

