Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6517DC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 03:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BDA12146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 03:20:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BDA12146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2B128E0004; Tue, 19 Feb 2019 22:20:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DA188E0002; Tue, 19 Feb 2019 22:20:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CA378E0004; Tue, 19 Feb 2019 22:20:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32ACC8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 22:20:42 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d9so9424140edh.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 19:20:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5nXAb/J9n5Mp2r8yWNp4JYx9j7pHkZr+SxNu3JlNsas=;
        b=WD/K6z1EBPqIUyJy42+cMQOnW/yEyTd/O/ARYXBJNTSkzRHYbN1+zwheTGFvpsrKw9
         4hWxh5narygxPQtmT9RiKX8BkQccF0s/u8y3Vv6FSLfuKRydG3BdibIDd8Qk7mPh2atz
         GCROXZ6uwcZyaXgUlUg2WSu+9sd1kG6J2zP/eqFwwq9p0LYf8JbYRMmyDm1B5i5Dzhy3
         T4pTe8AcK4j7jCbqx3VC0uzU9VImwSUh5l2WYj+8aIbga9TGA7/UdWwiaE8rAg/lGWAa
         bcltAOWr0+UzDmiUX4wmoswUSK0tAvu+dnMOhMvmTAXtIuNKbu8wDBG9zBVfC9C8gqRf
         xozQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaezDF+bwOU6Fy5yqiDJ/72pq6DFCNrW84wfGtlCd4dQrMnd0hA
	0HcwiRig+oUxquCejFBSwfdM7fVHc+luV8K1M8wJSEOg0MN0dxpIDuqPCW7tKc6Rg/ktOIP7oRF
	cuhROkOETeZllyfo3G0fmO66HlT2vUuxVPQMgjGgdz1hDdJhLp6BINfh6IB4Yb1x9aQ==
X-Received: by 2002:a50:b646:: with SMTP id c6mr5156824ede.149.1550632841665;
        Tue, 19 Feb 2019 19:20:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibr+bIkbS9uWEyuUVpNc9rRbQHdf9PZwP9u7rfePCO4aIqFFh6iiDWkryzICO0YSNIlNCYG
X-Received: by 2002:a50:b646:: with SMTP id c6mr5156785ede.149.1550632840598;
        Tue, 19 Feb 2019 19:20:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550632840; cv=none;
        d=google.com; s=arc-20160816;
        b=EGebdvmnjHaqO0Cm4ebfggutMHZLSB8ef/b6CXuR3PxbOh8sRqoTTaL6pquBJ7kbBg
         AHizxhAX3fIKd2FLJatM5Vj85sm0+Z1Wcys8gZaRAnQSDcMRUUqIh1n/TZvqbsZh0HGW
         0s0TCzfTHMdglZIUqbW7U78rr3sMWyd5dPoqUJn7NmsxBla2dhotK7ZKwKBR0Wl4yJmC
         5jtu2penE+ImuxwGC5W5kxCAReR0x+ZFzF10pwOam3X/FNswDivpwfRXLT/ntj6lxnSK
         V4bF4RZlmqViVVKZeBWwm+4fdTipSTgq4aizsBkh/uLlpzF2zm0BLPGZhBsEr+7gxuNF
         3VnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5nXAb/J9n5Mp2r8yWNp4JYx9j7pHkZr+SxNu3JlNsas=;
        b=YY94b9AkbN972Qbr9zkp049J8W1333NoU+ygENagc3vEDqo3Ps5ere0vXC+8nm3Ucs
         vNyRZbk5DD4t4yNpZVI5lFULL6BU+CSV1iAQZwwtPPCb8l0Ygr6oKRDemrsLKADFrYfc
         20EaWL7pUj+zmzxEJDvu8mPkOR80xr8PxY2xpwfb4GFbNQS6uqlabmq+nGu2yzBgEE9/
         mr2aTmC+lVQk5IIych2ttcqnCuG6FXBCVPcXYXcGeJgI5QFJz2oN2hnYB1rs+nQSUuEA
         p4j9XPxVoafPrxIEVZEMjMmlaRuSvmaS5c3BWPjLHqNeLCC03lvLiy1gqtmIayRLMGC5
         1t4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j21si2768739ejv.72.2019.02.19.19.20.40
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 19:20:40 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2C88FEBD;
	Tue, 19 Feb 2019 19:20:39 -0800 (PST)
Received: from [10.162.40.115] (p8cg001049571a15.blr.arm.com [10.162.40.115])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D7B833F720;
	Tue, 19 Feb 2019 19:20:33 -0800 (PST)
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
To: Matthew Wilcox <willy@infradead.org>
Cc: Yu Zhao <yuzhao@google.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Joel Fernandes <joel@joelfernandes.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Mark Rutland <mark.rutland@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>,
 Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
 <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
 <20190220013407.GD12668@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <383ced45-12be-ce51-187b-bb77cefdee7e@arm.com>
Date: Wed, 20 Feb 2019 08:50:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190220013407.GD12668@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/20/2019 07:04 AM, Matthew Wilcox wrote:
> On Tue, Feb 19, 2019 at 11:47:12AM +0530, Anshuman Khandual wrote:
>> + Matthew Wilcox
>> On 02/19/2019 11:02 AM, Yu Zhao wrote:
>>> On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
>>>>
>>>>
>>>> On 02/19/2019 04:43 AM, Yu Zhao wrote:
>>>>> For pte page, use pgtable_page_ctor(); for pmd page, use
>>>>> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
>>>>> p4d and pgd), don't use any.
>>>> pgtable_page_ctor()/dtor() is not optional for any level page table page
>>>> as it determines the struct page state and zone statistics.
>>>
>>> This is not true. pgtable_page_ctor() is only meant for user pte
>>> page. The name isn't perfect (we named it this way before we had
>>> split pmd page table lock, and never bothered to change it).
>>>
>>> The commit cccd843f54be ("mm: mark pages in use for page tables")
> 
> Where did you get that commit ID from?  In Linus' tree, it's
> 1d40a5ea01d53251c23c7be541d3f4a656cfc537
> 
>>> clearly states so:
>>>   Note that only pages currently accounted as NR_PAGETABLES are
>>>   tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.
>>
>> I think the commit is the following one and it does say so. But what is
>> the rationale of tagging only PTE page as PageTable and updating the zone
>> stat but not doing so for higher level page table pages ? Are not they
>> used as page table pages ? Should not they count towards NR_PAGETABLE ?
>>
>> 1d40a5ea01d53251c ("mm: mark pages in use for page tables")
> 
> I think they should all be accounted towards NR_PAGETABLE and marked
> as being PageTable.  Somebody needs to make the case for that and

Okay so we agree on the applicability part.

> send the patches.  That patch even says that there should be follow-up
> patches to do that.  I've been a little busy and haven't got back to it.
> I thought you said you were going to do it.

This is very much arch specific. pgtabe_page_ctor()/dtor() are not uniformly
called for all page table level allocations (user or kernel) across different
archs. Yes I am planning to make generic page table allocation functions for
all levels which archs can choose to use. But for now I have a series to fix
the situation on arm64.

> 
>> pgtable_page_ctor/dtor() use across arch is not consistent and there is a need
>> for generalization which has been already acknowledged earlier. But for now we
>> can atleast fix this on arm64.
>>
>> https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com/
> 
> ... were you not listening when you were told that was completely
> inadequate?

Agreed. The discussion on the thread made it clear that the above patch was
inadequate. What I was trying to point out (probably not very clearly) that
there is a need for larger generalization/consolidation on page table page
allocation front including but might not be limited to allocation flag for
user/kernel page table, standard allocation functions etc. The very idea of
quoting the above URL here was to bring attention to the fact that different
archs are doing these allocations differently already.

