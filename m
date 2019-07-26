Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E96FEC41514
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:02:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A961E206BA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:02:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A961E206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 402FB6B0003; Fri, 26 Jul 2019 02:02:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B2F06B0005; Fri, 26 Jul 2019 02:02:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27E848E0002; Fri, 26 Jul 2019 02:02:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE12E6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:02:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w25so33420327edu.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:02:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mxQjWzqybI9PqSVCZJCJK0K7mNtpday5Hlg5apeL7ns=;
        b=sH54Kff50zg6Oa7Rp/sWqyTH8CIvl8oYnVHJovKmd5A2PvscDs+TKqEle34xU8JhM/
         iZgI/3gny3tAy31TrvszisC1UXU+/x+PIEJ5xM+pT6Bxo8hrw1WKnq+inmZj00TM1b9g
         0cD56xxqqhQQ2Bw2AuZ0HwS6AfghdQpOzIr/3/plPwKGaufKPmVR9AZu/esRaM5Pzx0P
         oijC8MMToowsBoLzTgC+1ksQJCYts/WOBLTvvTNlN3F3BfUq0VVynfxjdBdAehW4EAkC
         9dpOUBYcBPTq2hnN2agO8GE3b9AR5BbDDEpzAB8bIz6uJB9eZavti/weFc4u8wuz3scu
         lz7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUKwTii8x5jXSZIDI9aJq/2vMWXl+/gqbypI1ca2q+5mS/z6mxz
	cLwKgm17hkAhZvmgTPbtvuBnhmIm6Iw6+T0JWbVLE6m+fwRO+6x9H6MtgLGY+iL2H43Cv2aVwK0
	LPnLqACdWy/k6dpSvEqCKHGng/pLMhfWZGL5ns7BGy2DgeceslJM9Jnmp5myJgANDgA==
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr69800948ejo.24.1564120964395;
        Thu, 25 Jul 2019 23:02:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZSjIYOqepsB0enkW73F5jzoSvHaTrkCvmYasrnn9cClcGQkYgN61T2OM5d/nXViOothMP
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr69800892ejo.24.1564120963606;
        Thu, 25 Jul 2019 23:02:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564120963; cv=none;
        d=google.com; s=arc-20160816;
        b=lb0FxfHhj1qjxz+SD2NwILGZFyQr+kcOsOhJs00Q/t/jVdihoi1pRmdU8RjXml7q02
         tRseDan5GC5L6Y1QqDnGrrWOcccOVnsHSlAOvAeA1Z57n/rvmDQ0f8mbX/xUHK9MaKVu
         H64UPwo5Q0gCJxT/Pu76dnY/198f4s2fnHxw98bZXqOX3pzpqM0zDpIZ4czhRG1r+I1v
         t+X5nmFxpM2/BSd7CniDvU2rgbVxkweAWcu8W7EbbZJFGmMlCUEmcyi0eb52i/9zKMCC
         FhqEsPldLdvQrT+Uv4PyHhImM7Oo8d1YInNuSmVQf8j3dcYhJN5nkPfdYMW+aRUS5Zc5
         VcEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mxQjWzqybI9PqSVCZJCJK0K7mNtpday5Hlg5apeL7ns=;
        b=lN7oV4o7DRsZEEnVvWkvZ+L7yWaeAmYwZnu8P/Px3GKZ6NG0J7+OW8vzdl36dVjxxo
         EaOhMndIqiQ3ZR3vXYa0kYO/Ui2clqSfU0kl+EQTyt2U2xbsxRhbrZgqT2PYFPPiLOj3
         d2uxBh24HgkM+lMoV8ipn022Nf7ivoytuXTcnM2p/RbZNYmOcjQb0ALSxtLCYsvZHQ+k
         +X9FnARBQ9kxn/m1MKreJ1qBWxAZggojpmg8KdNQt/8w8GyKbkkfErKOUH2S+aP9EE+j
         WXj2umt/Ep47gdO2wuYbng0ImQ3RAuLqNGdGDqEQ93pmBSAp5aTsvpDMyNtne14vf0an
         /ODA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id 47si13148182edu.294.2019.07.25.23.02.43
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 23:02:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8CE59337;
	Thu, 25 Jul 2019 23:02:42 -0700 (PDT)
Received: from [10.163.1.197] (unknown [10.163.1.197])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1F3E03F694;
	Thu, 25 Jul 2019 23:04:40 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Will Deacon <will@kernel.org>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
 Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <835a0f2e-328d-7f7f-e52a-b754137789f9@arm.com>
 <c9d2042f-c731-4705-4148-b38deccf7963@arm.com>
 <6f59521e-1f3e-6765-9a6f-c8eca4c0c154@arm.com>
 <20190725093036.dzn6uulcihhkohm2@willie-the-truck>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <40adc5ea-1125-d821-267d-3621732775d6@arm.com>
Date: Fri, 26 Jul 2019 11:33:14 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190725093036.dzn6uulcihhkohm2@willie-the-truck>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/25/2019 03:00 PM, Will Deacon wrote:
> On Thu, Jul 25, 2019 at 02:39:22PM +0530, Anshuman Khandual wrote:
>> On 07/24/2019 07:05 PM, Steven Price wrote:
>>> There isn't any problem as such with using p?d_large macros. However the
>>> name "large" has caused confusion in the past. In particular there are
>>> two types of "large" page:
>>>
>>> 1. leaf entries at high levels than normal ('sections' on Arm, for 4K
>>> pages this gives you 2MB and 1GB pages).
>>>
>>> 2. sets of contiguous entries that can share a TLB entry (the
>>> 'Contiguous bit' on Arm - which for 4K pages gives you 16 entries = 64
>>> KB 'pages').
>>
>> This is arm64 specific and AFAIK there are no other architectures where there
>> will be any confusion wrt p?d_large() not meaning a single entry.
>>
>> As you have noted before if we are printing individual entries with PTE_CONT
>> then they need not be identified as p??d_large(). In which case p?d_large()
>> can just safely point to p?d_sect() identifying regular huge leaf entries.
> 
> Steven's stuck in the middle of things here, but I do object to p?d_large()
> because I find it bonkers to have p?d_large() and p?d_huge() mean completely
> different things when they are synonyms in the English language.

Agreed that both p?d_large() and p?d_huge() should not exist at the same time
when they imply the same thing. I believe all these name proliferation happened
because THP, HugeTLB and kernel large mappings like linear, vmemmap, ioremap etc
which the platform code had to deal with in various forms.

> 
> Yes, p?d_leaf() matches the terminology used by the Arm architecture, but
> given that most page table structures are arranged as a 'tree', then it's
> not completely unreasonable, in my opinion. If you have a more descriptive
> name, we could use that instead. We could also paint it blue.

The alternate name chosen p?d_leaf() is absolutely fine and it describes the
entry as intended. There is no disagreement over that. My original concern
was introduction of yet another page table helper.

> 
>>> In many cases both give the same effect (reduce pressure on TLBs and
>>> requires contiguous and aligned physical addresses). But for this case
>>> we only care about the 'leaf' case (because the contiguous bit makes no
>>> difference to walking the page tables).
>>
>> Right and we can just safely identify section entries with it. What will be
>> the problem with that ? Again this is only arm64 specific.
>>
>>>
>>> As far as I'm aware p?d_large() currently implements the first and
>>> p?d_(trans_)huge() implements either 1 or 2 depending on the architecture.
>>
>> AFAIK option 2 exists only on arm6 platform. IIUC generic MM requires two
>> different huge page dentition from platform. HugeTLB identifies large entries
>> at PGD|PUD|PMD after converting it's content into PTE first. So there is no
>> need for direct large page definitions for other levels.
>>
>> 1. THP		- pmd_trans_huge()
>> 2. HugeTLB	- pte_huge()	   CONFIG_ARCH_WANT_GENERAL_HUGETLB is set
>>
>> A simple check for p?d_large() on mm/ and include/linux shows that there are
>> no existing usage for these in generic MM. Hence it is available.
> 
> Alternatively, it means we have a good opportunity to give it a better name
> before it spreads into the core code.

Fair enough, that is another way. So you expect existing platform definitions
for p?d_large()/p?d_huge() getting cleaned up and to start using new p?d_leaf()
instead ?

> 
>> IMHO the new addition of p?d_leaf() can be avoided and p?d_large() should be
>> cleaned up (if required) in platforms and used in generic functions.
> 
> Again, I disagree and think p?d_large() should be confined to arch code
> if it sticks around at all.

All of those instances should migrate to using p?d_leaf() eventually else
there will be three different helpers which probably mean the same thing.

