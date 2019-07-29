Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 644FBC76192
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:32:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CF7D206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:32:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CF7D206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 766DB8E0005; Mon, 29 Jul 2019 04:32:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 717CB8E0002; Mon, 29 Jul 2019 04:32:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E0FB8E0005; Mon, 29 Jul 2019 04:32:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 124AC8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:32:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so37838759edt.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:32:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IF708GymTQFOOI7nmy2euqjzzSXt9Zh89btFpnOof30=;
        b=MGdfunqNotDLF4T71Q3c4f0N8gtI9B7/Mi2h1n04YGR6Ar4p2o+AySZZ0D3Yp7XeAZ
         /HEeo3eHjJt4tgYf/wdAFdiSUh27yy46dTXCpjsbHhEqmnDxtR/9a7Ec1j41TJJJPRIP
         P+tkIqiYhg1LOJjNOWVw7vUIuyk0TyWyPFIV8ZniHLMUVByvnFAXAEf27zOYZZW2JHFy
         bsSeLoNHh9DHSB+0Z+MaV+9bAe7aUEPbRGmgddueIQ+JBPpk/OtaL2rAuPku0zQ9KyzQ
         ohpCSbCqD6bteDD2E4SYQxy+JuQ0605xViM4971YCcmLb66+DMMXni+ArdMgZqy29YuU
         AuqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVu4aNN9lEz2U3yfVzU9EwKoD5njJ5Yke5WFA1EZ8Un/YqR9wZI
	IuF8mhJmsPWI5GNS88rXn6R/BrkVALi/aYH5lQ/uWyWwGpZMI8MeigauKkK5Y59p1R4J2dvsq6P
	ouSPP1/CpjbAXV/JrAL1+SlqE5qkVSNCD29hg7WWbZyX7vsnK1RS9Ofnh+r0LJoHLxQ==
X-Received: by 2002:a17:907:20db:: with SMTP id qq27mr83122048ejb.30.1564389137510;
        Mon, 29 Jul 2019 01:32:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdyEkaJtGj++xxxqkzFIne7QMcnAzJW97fcpsvndFarQ3a7pboxfkA1zpzIPDPvhz52Qss
X-Received: by 2002:a17:907:20db:: with SMTP id qq27mr83122002ejb.30.1564389136690;
        Mon, 29 Jul 2019 01:32:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564389136; cv=none;
        d=google.com; s=arc-20160816;
        b=ZRRoCmDTzxSU0+DsJMJ+R8grFPPAO57eCFzrA5KXjJBX45xh8qKoMm4R6pkScQXd+O
         GPI8O7IzIf7wOJEm18gT2Rl/1wVD5heNcf/wQNqmxq1qwBTK0x07pv2U7dkzB7G3Zhhm
         7HvN0pPHhUqoJfNtc9t0XdIoahDQvPFv3xlVK0BDJiyRhsBUIvTukut1yKjAqibCqUoT
         H+P9FCQQ81YcZbvFfmUJvyx33rV9VMmOqMMgYrtR0nsmdoFJ0W4J7jJtiUZguuEF9DFV
         jA8gg1lNeuyl6b428MqzDM1Ql2OZqlQUnXg9MS/ejG0uTH6izdULBzEvwJGvaU5Q2niE
         Q7ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IF708GymTQFOOI7nmy2euqjzzSXt9Zh89btFpnOof30=;
        b=W4f8yy6pQUZd+6Vi9tZouaJToZ14b+RSfRDGz6koRfcPW3qQx9/BlLl/+X48Y90UYD
         cGGMH6cnVH8aBeSxnDJMPau2K//6mJssdgsrjCvlW3tEKIa70hy1OsKniTAbCoj4ZGBy
         yeO00h3YkJ8VdyxgRtXTW8PltRy1YJzz6A8tdSSFWRi22aELZ8dg+n/aUY8Rrtm9fhm1
         dF2J91qghZityj2QkoAJQm/JpqqLXxl5HoLREIZyj4xF1pFzvXry2EZeRQjn6n5qqSHV
         sPUmlsKiN7l9Cmmb9t67MG8XyfTb+VQIsuWo1ZDmVYI+juxcJKl+5nTYRXSh08iS++Ve
         YYSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x51si16864654edm.42.2019.07.29.01.32.16
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 01:32:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A9CDF337;
	Mon, 29 Jul 2019 01:32:15 -0700 (PDT)
Received: from [10.162.40.126] (p8cg001049571a15.blr.arm.com [10.162.40.126])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 990293F575;
	Mon, 29 Jul 2019 01:32:11 -0700 (PDT)
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Mark Brown <Mark.Brown@arm.com>, Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>, linux-arm-kernel@lists.infradead.org,
 x86@kernel.org, linux-kernel@vger.kernel.org
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
 <c3bb0420-584c-de3b-2439-8702bc09595e@arm.com>
 <20190726195457.GI30641@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <10ed1022-a5c0-c80c-c0c9-025bb2307666@arm.com>
Date: Mon, 29 Jul 2019 14:02:52 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190726195457.GI30641@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/27/2019 01:24 AM, Matthew Wilcox wrote:
> On Fri, Jul 26, 2019 at 10:17:11AM +0530, Anshuman Khandual wrote:
>>> But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
>>> architectures doing the right thing if asked to make a PMD for a randomly
>>> aligned page.
>>>
>>> How about finding the physical address of something like kernel_init(),
>>
>> Physical address corresponding to the symbol in the kernel text segment ?
> 
> Yes.  We need the address of something that's definitely memory.
> The stack might be in vmalloc space.  We can't allocate memory from the
> allocator that's PUD-aligned.  This seems like a reasonable approximation
> to something that might work.

Okay sure. What is about vmalloc space being PUD aligned and how that is
problematic here ? Could you please give some details. Just being curious.

> 
>>> and using the corresponding pte/pmd/pud/p4d/pgd that encompasses that
>>
>> So I guess this will help us use pte/pmd/pud/p4d/pgd entries from a real and
>> present mapping rather then making them up for test purpose. Although we are
>> not creating real page tables here just wondering if this could some how
>> affect these real mapping in anyway from some accessors. The current proposal
>> stays clear from anything real - allocates, evaluates and releases.
> 
> I think that's a mistake.  As Russell said, the ARM p*d manipulation
> functions expect to operate on tables, not on individual entries
> constructed on the stack.

Hmm. I assume that it will take care of dual 32 bit entry updates on arm
platform through various helper functions as Russel had mentioned earlier.
After we create page table with p?d_alloc() functions and pick an entry at
each page table level.

> 
> So I think the right thing to do here is allocate an mm, then do the
> pgd_alloc / p4d_alloc / pud_alloc / pmd_alloc / pte_alloc() steps giving
> you real page tables that you can manipulate.
> 
> Then destroy them, of course.  And don't access through them.

mm_alloc() seems like a comprehensive helper to allocate and initialize a
mm_struct. But could we use mm_init() with 'current' in the driver context or we
need to create a dummy task_struct for this purpose. Some initial tests show that
p?d_alloc() and p?d_free() at each level with a fixed virtual address gives p?d_t
entries required at various page table level to test upon.

> 
>>>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>>>> +static void pud_basic_tests(void)
>>>
>>> Is this the right ifdef?
>>
>> IIUC THP at PUD is where the pud_t entries are directly operated upon and the
>> corresponding accessors are present only when HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>> is enabled. Am I missing something here ?
> 
> Maybe I am.  I thought we could end up operating on PUDs for kernel mappings,
> even without transparent hugepages turned on.

In generic MM ? IIUC except ioremap mapping all other PUD handling for kernel virtual
range is platform specific. All the helpers used in the function pud_basic_tests() are
part of THP and used in mm/huge_memory.c

