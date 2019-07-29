Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3637DC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:34:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFC6E214AE
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:34:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC6E214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79AB28E0003; Mon, 29 Jul 2019 08:34:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74B178E0002; Mon, 29 Jul 2019 08:34:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 660EE8E0003; Mon, 29 Jul 2019 08:34:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18BE18E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:34:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so38204484edr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:34:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iy8CtCvUK/X0Mf7iemEryUaudCdZUro4kY2MKyBrdoc=;
        b=BStIKLpK2Pus7e8mupGuFRy/tgHwqt+i/GQisMgVWmhC4Q4w8tFfVKFYvTPB0iu+HG
         QKbkq8jWZCU2GK0ZBtLFGHR+LOiQvfay76I5NJyNP6SbO0IKRwCSArzAXQR+7KDOJu2u
         0DMvyGdrLAdNlIgub7I8yc/nOV2/MN5dnnCC6MfUEvW+32vIHb4HgU4LmNawqRSITXpa
         AMczk8fZp9mgD5gJm8xrUMC1vkVRlKVeV0LM4LmbOg0UhsbwDUWGFJxHCCPGMIFUS4kl
         we4PU427WxPCo3odTd7PT+myIWmrN0ywUfuTtfS1K3pDxkWZq7FmX3Gj+Lxyhb6EuQa6
         O2RQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVIGkF2+PBwFi8tyR/DBU+Z9c/5fQw6kRj9mWngRb/COsuLGdoX
	Wd3BTaAjlj6WZjmvFfeR42xqJJhvptWRGxeEbyKzsRt5GcLQShg8DX4B63k0XfJVgti66OcExSj
	CerK57EIst7e/LjOofNBBDWXESXKaPTup4jYxwd+v+TsJ6S91l796v044MV7aObuCMA==
X-Received: by 2002:a17:906:7382:: with SMTP id f2mr82269650ejl.88.1564403694658;
        Mon, 29 Jul 2019 05:34:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhuIP6TxC4odVSo4i6Jb5bCiDJu41LG20EpHIsqIb1rwZY1DjYhqJUNJrhHelxLFwchtt8
X-Received: by 2002:a17:906:7382:: with SMTP id f2mr82269600ejl.88.1564403693952;
        Mon, 29 Jul 2019 05:34:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564403693; cv=none;
        d=google.com; s=arc-20160816;
        b=j8Yo6a58ouwBqTIQrXZrvilI1h/SCyeHiebPLAJx1clQaDbE+tL83B5FeDCOKC3wD4
         D5HmnxMT5g6mcY2kah/S0sjADQLKr26Jn3awwNORhAh47FUcR/L0gqibep49Wy5Gt7cE
         yd9xfMu+j2PGidUm0tsnRJhP2+yp0T4pJauvd80DBXS42Wj6hGEo749BGPb2eezus+f1
         8NTVuYOqXaLQuIuQEtRzJ12SlCQ6lqFKIG4qixlWv0xe3AON8w5bPav4BucTGHItSnTv
         pp56kzNSPbzGpo6ZBg59lNxRawnBj7ZzfttAEEc6rV/fqQApytV2lzuLbDu/NPkP4Ld1
         wYYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iy8CtCvUK/X0Mf7iemEryUaudCdZUro4kY2MKyBrdoc=;
        b=NYJZBpMZoJfuc5W9VtCTM/S04OqXhK9x9amGBTCmcZDyYXWyeo/6EIn7l31CriuluZ
         tAlZBTj5eSFnyoP+NKShjxbrJ1RsGCbeLBm5VOstqxWfElmCayyr1/dlL1ln92edh/aP
         t8upjcEBU/CCx5bjrsQslTYwKQ44RVwK5TaHaNygaoDB3ZXK+g69xUD+ZDzySS84aVrZ
         j8xzfwhNPoiw3rdEbSN+M+2Iq+/f6u/0UBfbQ5qwIZptl8ZX2gjHwM90zOTLK2/314/U
         eAArhrDg0kqL2jdb8lVbG1ROfC4l4qoZ5UI7V7T3rqz12V19RnpXveFiolWyZo7vzyL/
         /fRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r2si17687616eda.213.2019.07.29.05.34.53
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 05:34:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 83BF228;
	Mon, 29 Jul 2019 05:34:52 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 117973F575;
	Mon, 29 Jul 2019 05:34:49 -0700 (PDT)
Subject: Re: [PATCH v9 13/21] mm: pagewalk: Add test_p?d callbacks
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
 <20190722154210.42799-14-steven.price@arm.com>
 <b74e545f-cbe0-9dd0-004c-5919e5cabb6f@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <df6f5233-6630-2d21-ad38-2520644c0c87@arm.com>
Date: Mon, 29 Jul 2019 13:34:48 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <b74e545f-cbe0-9dd0-004c-5919e5cabb6f@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/07/2019 14:41, Anshuman Khandual wrote:
> 
> 
> On 07/22/2019 09:12 PM, Steven Price wrote:
>> It is useful to be able to skip parts of the page table tree even when
>> walking without VMAs. Add test_p?d callbacks similar to test_walk but
>> which are called just before a table at that level is walked. If the
>> callback returns non-zero then the entire table is skipped.
>>
>> Signed-off-by: Steven Price <steven.price@arm.com>
>> ---
>>  include/linux/mm.h | 11 +++++++++++
>>  mm/pagewalk.c      | 24 ++++++++++++++++++++++++
>>  2 files changed, 35 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index b22799129128..325a1ca6f820 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1447,6 +1447,11 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>>   *             value means "do page table walk over the current vma,"
>>   *             and a negative one means "abort current page table walk
>>   *             right now." 1 means "skip the current vma."
>> + * @test_pmd:  similar to test_walk(), but called for every pmd.
>> + * @test_pud:  similar to test_walk(), but called for every pud.
>> + * @test_p4d:  similar to test_walk(), but called for every p4d.
>> + *             Returning 0 means walk this part of the page tables,
>> + *             returning 1 means to skip this range.
>>   * @mm:        mm_struct representing the target process of page table walk
>>   * @vma:       vma currently walked (NULL if walking outside vmas)
>>   * @private:   private data for callbacks' usage
>> @@ -1471,6 +1476,12 @@ struct mm_walk {
>>  			     struct mm_walk *walk);
>>  	int (*test_walk)(unsigned long addr, unsigned long next,
>>  			struct mm_walk *walk);
>> +	int (*test_pmd)(unsigned long addr, unsigned long next,
>> +			pmd_t *pmd_start, struct mm_walk *walk);
>> +	int (*test_pud)(unsigned long addr, unsigned long next,
>> +			pud_t *pud_start, struct mm_walk *walk);
>> +	int (*test_p4d)(unsigned long addr, unsigned long next,
>> +			p4d_t *p4d_start, struct mm_walk *walk);
>>  	struct mm_struct *mm;
>>  	struct vm_area_struct *vma;
>>  	void *private;
>> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
>> index 1cbef99e9258..6bea79b95be3 100644
>> --- a/mm/pagewalk.c
>> +++ b/mm/pagewalk.c
>> @@ -32,6 +32,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>>  	unsigned long next;
>>  	int err = 0;
>>  
>> +	if (walk->test_pmd) {
>> +		err = walk->test_pmd(addr, end, pmd_offset(pud, 0UL), walk);
>> +		if (err < 0)
>> +			return err;
>> +		if (err > 0)
>> +			return 0;
>> +	}
> 
> Though this attempts to match semantics with test_walk() and be comprehensive
> just wondering what are the real world situations when page walking need to be
> aborted based on error condition at a given page table level.

I'm not aware of a situation yet where aborting early is necessary - but
as you say this matches the semantics of test_walk() and was easy to
implement.

Steve

