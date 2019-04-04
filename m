Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9877C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:16:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8074220652
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:16:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8074220652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 181346B0005; Thu,  4 Apr 2019 05:16:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 130E26B0008; Thu,  4 Apr 2019 05:16:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B5A6B000E; Thu,  4 Apr 2019 05:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A47B46B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:16:56 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e16so1068418edj.1
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:16:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=TNFbuiNLWimb6q6rVhNX5raXOrM/OF6l5mNMpaB9C3I=;
        b=jjKYwpRzMwg6i4M8syJvdke5jZp/o0jmdAOD4bnbaegu5P/QSX9Hq18e5Zh+9bDdZe
         5pVORBMLjfB9lHLREKBpRFPsIc9xh8QXh2E5J8ymNBnEYwerzURqlufg2o2nWsrkrLN5
         fZzoBfONiTrl8nwe+pg91lJD/Fzey820vfcbMx3/fPMkIA9QZ6WGKWQwlHsc519ej0+I
         ZuXDt4USa7bYGgbfk22ZV9IonLDrVKvm/02quiZ8MBXTd+cJUH/W74+nd3hMf3bMSdwy
         F7LxbuzNcwge6olcdHrw2bGf8mN8e+Ac+MUTlSJe2Er3g9F1HAHHixPO9Cva0v4fRQg5
         e3lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWm9aRdoGuldoyEtNhJaBCW2vde0OPEqD5KVuEfeswp/DfMyh8s
	vlJ8xuNDIkA6W7Rl6lNLZgJtUj8OVCdfjU+DOOWsuE0hw1u+bG39VugP7aT46s2bDYYIMqbDOXT
	e/+2PjSVzvuWgAT5l9w64TQsah5ohayig9CIIh1p5Ne4dleeigXw1889WRD+lPPsITQ==
X-Received: by 2002:a17:906:5a09:: with SMTP id p9mr2954869ejq.46.1554369416226;
        Thu, 04 Apr 2019 02:16:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLdkcPJHTE5u9cvLvX5knBOHpMQyGcXXeYFCvRfE38stW3Fccf4R0UF0gEwkSRwb6Zjxe0
X-Received: by 2002:a17:906:5a09:: with SMTP id p9mr2954817ejq.46.1554369415179;
        Thu, 04 Apr 2019 02:16:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554369415; cv=none;
        d=google.com; s=arc-20160816;
        b=ZvPpmMuRrI17VCqXwxc/AtsUns7UJPaVqqvemfuE4PMjrIoGLhT2fqd2Rc3xxB9j4Z
         NPBklilwFPIRix4hlSweBSh/0rXoQp8o1G4a8YyXzGFiVo7SgzfgZoXYc8INpWgxgFEE
         W9ND6SwAw3MBtHSm7Fsl134bQ7m1xgnpeYFLXPJR50qIHneASaBhI+H0tTZDFDS5M7zA
         w1usnJ/kSOzI6V2pYM9Tmfgg8OxJCXagnuVprQb6SLjwg6qirD9Vvd4zE5k+Zug/LeOW
         X8yUFxgclWvHD03gbF6vQ9B/TPwR3jBNeFLeJPyldms5q9PnHaTxseSwg2IoS79SQP7/
         KWKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=TNFbuiNLWimb6q6rVhNX5raXOrM/OF6l5mNMpaB9C3I=;
        b=F0wN6FUkCIXQuAx/F82DOI7BHIjQ6psBeEVs6J5etu9GkPNT0aFeCoPeqtUA4LLw+u
         Wim6RfTzEXosEstmf4u+LUAn1CN14aRLJowZ1u2aHrTmT4gnjOG5JCKmUhYxj/KTrLGh
         xMHEz2CZYkJFD8qz/t9RHx8sQq9cFSh+L5d7N4yH4/9Aq3LUJTnSWGYLN7HJw2TryeZu
         vdY5cuuHjxvHuqZRKoz/ylPAY/vCC80jpGqAcy72qyx/i/pj2v0hG3G5K803r3jS0zjx
         lSbUpAPoGElbrJjkyuMJv97Nq6+fBKted86WYid9jlKOWkSSJsR/nCCck9BEU5gphXgH
         Q6fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w42si430363edd.305.2019.04.04.02.16.54
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 02:16:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D54E8168F;
	Thu,  4 Apr 2019 02:16:53 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 757D73F557;
	Thu,  4 Apr 2019 02:16:50 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mark.rutland@arm.com, mhocko@suse.com, david@redhat.com,
 robin.murphy@arm.com, cai@lca.pw, pasha.tatashin@oracle.com,
 Stephen Bates <sbates@raithlin.com>, james.morse@arm.com,
 cpandya@codeaurora.org, arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
 <45afb99f-5785-4048-a748-4e0f06b06b31@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <1d1d69d1-06e6-f429-f22b-00ca922a314d@arm.com>
Date: Thu, 4 Apr 2019 10:16:48 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <45afb99f-5785-4048-a748-4e0f06b06b31@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/04/2019 08:07, Anshuman Khandual wrote:
> 
> 
> On 04/03/2019 11:02 PM, Logan Gunthorpe wrote:
>>
>>
>> On 2019-04-02 10:30 p.m., Anshuman Khandual wrote:
>>> Memory removal from an arch perspective involves tearing down two different
>>> kernel based mappings i.e vmemmap and linear while releasing related page
>>> table pages allocated for the physical memory range to be removed.
>>>
>>> Define a common kernel page table tear down helper remove_pagetable() which
>>> can be used to unmap given kernel virtual address range. In effect it can
>>> tear down both vmemap or kernel linear mappings. This new helper is called
>>> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
>>> The argument 'direct' here identifies kernel linear mappings.
>>>
>>> Vmemmap mappings page table pages are allocated through sparse mem helper
>>> functions like vmemmap_alloc_block() which does not cycle the pages through
>>> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
>>> destructor construct pgtable_page_dtor().
>>>
>>> While here update arch_add_mempory() to handle __add_pages() failures by
>>> just unmapping recently added kernel linear mapping. Now enable memory hot
>>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>>
>>> This implementation is overall inspired from kernel page table tear down
>>> procedure on X86 architecture.
>>
>> I've been working on very similar things for RISC-V. In fact, I'm
>> currently in progress on a very similar stripped down version of
>> remove_pagetable(). (Though I'm fairly certain I've done a bunch of
>> stuff wrong.)
>>
>> Would it be possible to move this work into common code that can be used
>> by all arches? Seems like, to start, we should be able to support both
>> arm64 and RISC-V... and maybe even x86 too.
>>
>> I'd be happy to help integrate and test such functions in RISC-V.
> 
> Sure that will be great. The only impediment is pgtable_page_ctor() for kernel
> linear mapping. This series is based on current arm64 where linear mapping
> pgtable pages go through pgtable_page_ctor() init sequence but that might be
> changing soon. If RISC-V does not have pgtable_page_ctor() init for linear
> mapping and no other arch specific stuff later on we can try to consolidate
> remove_pagetable() atleast for both the architectures.
> 
> Then I wondering whether I can transition pud|pmd_large() to pud|pmd_sect().

The first 10 patches of my generic page walk series[1] adds p?d_large()
as a common feature, so probably best sticking with p?d_large() if this
is going to be common and basing on top of those patches.

[1]
https://lore.kernel.org/lkml/20190403141627.11664-1-steven.price@arm.com/T/

Steve

