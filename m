Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F09CFC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A74C52173E
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:15:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A74C52173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FAE88E0063; Thu, 25 Jul 2019 06:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AB058E0059; Thu, 25 Jul 2019 06:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C1478E0063; Thu, 25 Jul 2019 06:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D02018E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:15:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so31876099eda.2
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:15:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=JxmxEvvBt/wSRPqaq44kRyALiQEnedswASXKnpI6rH0=;
        b=MrDARtOJCD5V5n/yeo5cAuoc8lKHJ3xSDPfO1NRY31y+i+bVfXEce4b01lLqjxUWoO
         pgpCnK234Vu3NcNdSY8CVUdr7G+/PRCfIrwcdepRVns1ZFURku8x1yA/CSY38NSZmW/c
         yIXAyg8OZ7hD/5d5EXuzuUyvPHzlognuLrI9YhhXWK61yCSHXaDTdDXtx9/3jexFp34P
         NE89ZLqpGHGDcTKHBzmJe6QGX335NKQAtAGB1bi+f8aj7Nr3CjyxIILKujushJMyPQh3
         tej0dgUosjhXTidQ9uYu5tzOyxtgX9W4xe3Jj4tss7yRxg6Ut/xEYK/hVymLh58Ta4+O
         fW1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXyQSrrcm7sJd/AfSAthkrzNpXIpA54ftJO0/5hRpjNLi+DHP+x
	fZbWisFUQ590lCpKZpEnhofPtynNerDi6zeFrQ/O9hJF1tLuABTbt15igOvCE7fzuSMUVSRC89R
	VuySayBaCKhUmxFuJKUHBODk/rPWgTV0pKHITmAj245zSXypJ8W4mWSe5r6AfMYn4DA==
X-Received: by 2002:a50:e619:: with SMTP id y25mr76077239edm.247.1564049726371;
        Thu, 25 Jul 2019 03:15:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsCMW1YnobUyvL6fAdXdr+p92Bq9B0Bhauj0WaURGVxjLgFkj6qTlH4k5oS64R6sBOACyy
X-Received: by 2002:a50:e619:: with SMTP id y25mr76077163edm.247.1564049725424;
        Thu, 25 Jul 2019 03:15:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564049725; cv=none;
        d=google.com; s=arc-20160816;
        b=Ck2uqnn2Fz6PFsTAjbNZWve8AjPTHBxkanNdpR7k18FDzAlFmOxJVsj1QT8Q2zJo45
         abX91LMHBON4nAwNb6ILyksXzdMeIMyz5BvpJiZJKWcPsnvk4yPaLN98OdfLoh6zg1/H
         +0kaFWrZzO8XzVr+E9WIPrhKbzib05uKvQ7iCxZXoUF/IzP68LCh5ihubzDIgt2YeQXN
         I8WDoa8DK3jWsfAOZ5FB2hgkLBZQmYKc0RpSXl82kHeiwl7mRa9lbsNy2FpULA4cw7qW
         /go/+n5duQq4312pVTtW6652cK/hfHbW97m2cZSzucDYtwdVJjWzbODFx++nLM5cZy+8
         00Dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=JxmxEvvBt/wSRPqaq44kRyALiQEnedswASXKnpI6rH0=;
        b=H2Ha7oFdEz/CDKYvSxhtVbw2QOc9gHKnRl43/p/mvsCu0l2zefvgxZ6E1YgXHwaZZ+
         Nrjk3QHPiCWEjQaDNn05E4F+myledYXVhhUNGBVO0w5D5v6CX33UPYBTkZUZBraqYN2D
         F/4mXtrFxOQGWO/yRP6GX9m0Ckm5Z9DO0+QtTpPeYAoyi1SJoi4VdhjXbpi7QjtNIOAa
         j6NMMhnxfOhwnBtSV3xhzLytDa251BIJmakcjm1O66vbjumOP2cK3/HZkyJ9j/8OOcSE
         7B8Ve9wpRD4mxQAnwJv/Mw114Kr40ErUmzkDdaHQQvqlhvnybHQfEta3EpkBS/cCTvMM
         ym0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x41si9853206edb.240.2019.07.25.03.15.25
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 03:15:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8904428;
	Thu, 25 Jul 2019 03:15:24 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 70CE23F694;
	Thu, 25 Jul 2019 03:15:21 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 linux-kernel@vger.kernel.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, James Morse <james.morse@arm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <835a0f2e-328d-7f7f-e52a-b754137789f9@arm.com>
 <c9d2042f-c731-4705-4148-b38deccf7963@arm.com>
 <6f59521e-1f3e-6765-9a6f-c8eca4c0c154@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <98ef7a4b-ee45-678e-4ec0-e982d70d3163@arm.com>
Date: Thu, 25 Jul 2019 11:15:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <6f59521e-1f3e-6765-9a6f-c8eca4c0c154@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25/07/2019 10:09, Anshuman Khandual wrote:
> 
> 
> On 07/24/2019 07:05 PM, Steven Price wrote:
>> On 23/07/2019 07:39, Anshuman Khandual wrote:
>>> Hello Steven,
>>>
>>> On 07/22/2019 09:11 PM, Steven Price wrote:
>>>> This is a slight reworking and extension of my previous patch set
>>>> (Convert x86 & arm64 to use generic page walk), but I've continued the
>>>> version numbering as most of the changes are the same. In particular
>>>> this series ends with a generic PTDUMP implemention for arm64 and x86.
>>>>
>>>> Many architectures current have a debugfs file for dumping the kernel
>>>> page tables. Currently each architecture has to implement custom
>>>> functions for this because the details of walking the page tables used
>>>> by the kernel are different between architectures.
>>>>
>>>> This series extends the capabilities of walk_page_range() so that it can
>>>> deal with the page tables of the kernel (which have no VMAs and can
>>>> contain larger huge pages than exist for user space). A generic PTDUMP
>>>> implementation is the implemented making use of the new functionality of
>>>> walk_page_range() and finally arm64 and x86 are switch to using it,
>>>> removing the custom table walkers.
>>>
>>> Could other architectures just enable this new generic PTDUMP feature if
>>> required without much problem ?
>>
>> The generic PTDUMP is implemented as a library - so the architectures
>> would have to provide the call into ptdump_walk_pgd() and provide the
>> necessary callback note_page() which formats the lines in the output.
> 
> Though I understand that the leaf flag (any given level) details are very much
> arch specific would there be any possibility for note_page() call back to be
> unified as well. This is extracted from current PTDUMP output on arm64.
> 
> 0xffffffc000000000-0xffffffc000080000  512K PTE  RW NX SHD AF  UXN MEM/NORMAL
> 
> The first three columns are generic
> 
> 1. Kernel virtual range span
> 2. Kernel virtual range size
> 3. Kernel virtual range mapping level
> 
> Where as rest of the output are architecture specific page table entry flags.
> Just wondering if we could print the first three columns in ptdump_walk_pgd()
> itself before calling arch specific callback to fetch a print buffer for rest
> of the line bounded with some character limit so that line does not overflow.
> Its not something which must be done but I guess it's worth giving it a try.
> This will help consolidate ptdump_walk_pgd() further.

It's not quite as simple as it seems. One of the things note_page() does
is work out whether a contiguous set of pages are "the same" (i.e.
should appear as one range). This is ultimately an architecture specific
decision: we need to look at the flags to do this.

I'm of course happy to be proved wrong if you can see a neat way of
making this work.

>>
>> Hopefully the implementation is generic enough that it should be
>> flexible enough to work for most architectures.
>>
>> arm, powerpc and s390 are the obvious architectures to convert next as
>> they already have note_page() functions which shouldn't be too difficult
>> to convert to match the callback prototype.
> 
> Which can be done independently later on, fair enough.
> 
>>
>>>>
>>>> To enable a generic page table walker to walk the unusual mappings of
>>>> the kernel we need to implement a set of functions which let us know
>>>> when the walker has reached the leaf entry. After a suggestion from Will
>>>> Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
>>>> the purpose (and is a new name so has no historic baggage). Some
>>>> architectures have p?d_large macros but this is easily confused with
>>>> "large pages".
>>>
>>> I have not been following the previous version of the series closely, hence
>>> might be missing something here. But p?d_large() which identifies large
>>> mappings on a given level can only signify a leaf entry. Large pages on the
>>> table exist only as leaf entries. So what is the problem for it being used
>>> directly instead. Is there any possibility in the kernel mapping when these
>>> large pages are not leaf entries ?
>>
>> There isn't any problem as such with using p?d_large macros. However the
>> name "large" has caused confusion in the past. In particular there are
>> two types of "large" page:
>>
>> 1. leaf entries at high levels than normal ('sections' on Arm, for 4K
>> pages this gives you 2MB and 1GB pages).
>>
>> 2. sets of contiguous entries that can share a TLB entry (the
>> 'Contiguous bit' on Arm - which for 4K pages gives you 16 entries = 64
>> KB 'pages').
> 
> This is arm64 specific and AFAIK there are no other architectures where there
> will be any confusion wrt p?d_large() not meaning a single entry.

This isn't arm64 specific (or even Arm specific) - only the examples I
gave are. There are several architectures with software walks where the
TLB can be populated with arbitrary sized entries. I have to admit I
don't fully understand the page table layouts of many of the other
architectures that Linux supports.

> As you have noted before if we are printing individual entries with PTE_CONT
> then they need not be identified as p??d_large(). In which case p?d_large()
> can just safely point to p?d_sect() identifying regular huge leaf entries.

The printing is largely irrelevant here (it's handled by arch code), so
PTE_CONT isn't a problem. However to walk the page tables we need to
know precisely "is this the leaf of the tree", we don't really care what
size page is being mapped, just whether we should continue the walk or not.

>>
>> In many cases both give the same effect (reduce pressure on TLBs and
>> requires contiguous and aligned physical addresses). But for this case
>> we only care about the 'leaf' case (because the contiguous bit makes no
>> difference to walking the page tables).
> 
> Right and we can just safely identify section entries with it. What will be
> the problem with that ? Again this is only arm64 specific.

It's not arm64 specific.

>>
>> As far as I'm aware p?d_large() currently implements the first and
>> p?d_(trans_)huge() implements either 1 or 2 depending on the architecture.
> 
> AFAIK option 2 exists only on arm6 platform. IIUC generic MM requires two
> different huge page dentition from platform. HugeTLB identifies large entries
> at PGD|PUD|PMD after converting it's content into PTE first. So there is no
> need for direct large page definitions for other levels.
> 
> 1. THP		- pmd_trans_huge()
> 2. HugeTLB	- pte_huge()	   CONFIG_ARCH_WANT_GENERAL_HUGETLB is set
> 
> A simple check for p?d_large() on mm/ and include/linux shows that there are
> no existing usage for these in generic MM. Hence it is available.

As Will has already replied - this is probably a good opportunity to
pick a better name - arch code can then be tidied up to use the new name.

[...]
> 
> Currently that is a difference between x86 and arm64 ptdump output. Whether to
> show the gaps or not could not be achieved by defining a note_page() callback
> function which does nothing but just return ? But if the single line output is
> split between generic and callback as I had proposed earlier this will not be
> possible any more as half the line would have been already printed.

I think the proposal at the moment is for arm64 to match x86 as it seems
like it would be useful to know at what level the gaps are. But I also
like giving each arch the flexibility to display what information is
relevant for that architecture. It's the custom page walkers I'm trying
to remove as really there isn't much difference between architectures
there (as lots of generic code has to deal with page tables in one way
or another).

Steve

