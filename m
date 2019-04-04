Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0279BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 06:51:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E379206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 06:51:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E379206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D586B0005; Thu,  4 Apr 2019 02:51:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBD766B0007; Thu,  4 Apr 2019 02:51:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAC276B0008; Thu,  4 Apr 2019 02:51:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2706B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 02:51:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c40so848856eda.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 23:51:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cxIwiceVjfR/9bUFid3FlngaTvdWiCleRmGC0rzqHZk=;
        b=AVkwLr9Yh1CiC3yvDpAw+Hr7aKnLyytnqbYiVJBZJZgPg6xG9uoHKWo58u76DSW9c+
         tOf5R9RXtpS7w4C0XX0tDIifAB35Pd/TVimxPsFoO1iTXfc4D6wL+4R0bsKELO7QW0gl
         eCiadNWOpLdJzWJNLk+3QZOkEB8Ady80K/hKuscMkWskdVUot5rX5mLzS2CN1o1QcEDm
         nxoX7B4FUVKrj4ZmT6l4yqOOchZzLAjWrGSIRXMocDqcNGBmrWPb31liVJY9J0w11sby
         W3aT+fttfA2FagiEh7MdKA6+yy6ix2ClvhdQS5PHS0C8xjdWNzadmOWMdaEspa4UCO02
         wewQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWizaFWiaI+c2v6jXAJNZIgXBW77ZdoswgOTbMS9cFh8oNJTMVo
	hgHtELf7C81HE4A6/Y4iReN5kuOWNwel9kMWfakUJH9bZrVTxutXO/H6jLJGarTgYfUivAuEECS
	6PfuEL8/OSoYqDnxT5RX0zmV8vgwsInWAIDc9xYQWUZjjbr94kodQodhK74guLVR3Iw==
X-Received: by 2002:a17:906:4408:: with SMTP id x8mr2419552ejo.93.1554360695026;
        Wed, 03 Apr 2019 23:51:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzox68YkwXcy8K/qxRZF2mO/WRfEHBuKy49A9kA2SJdRiG6KJvNSNKa0Cpl8yeA029PvnF6
X-Received: by 2002:a17:906:4408:: with SMTP id x8mr2419486ejo.93.1554360693674;
        Wed, 03 Apr 2019 23:51:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554360693; cv=none;
        d=google.com; s=arc-20160816;
        b=ffl2zE82WAotZuxccZBI17OXiBHp2dE7royyhpNi1XCazDT88UKouY1wMEXmhZdS+c
         +b5iH2sxdjHoqL9wZNv8vaS8aYiqeEeT8py1+RCCoTNn3coQiagMa+tZLVdXtQh5OFk3
         VKonDptubTeFHLx7gXYURHaS6usfyNn84RuAPo9fGtN8ZiREqd9kPjaDIjlhrfgpiqiT
         fqVMGm2/VpGxSU+rNO3MKz4UzOw6OA7ui16ZWg4PJ+ndaqSu2keW6HPXN5WbT1gAo0k+
         zcalyvj8WTFGd0eDRnxW/H8WTjw7fuK7k68O5R0YIW32aAwN9ldz2hMX+YfbobQdIEhO
         Epmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cxIwiceVjfR/9bUFid3FlngaTvdWiCleRmGC0rzqHZk=;
        b=xwx+ro25qc6c/CB12pbhEPusRL2DGoF+a04eVhlhsD7UDpKpZCyPEg1Bznfy42fbH+
         SW16TOdIH9F0VpKV5BMlsbTWgkILEZfYQOgyjuR5gI01gdVBQAynfVuzU8ojQVjHvMtm
         oAjE/egI/HfxZ822eps9h/VhusNR0FaUnJ1cYRBY4Nt2bRot4J17lMsW+UWctQ3MSOJ1
         8h9tnDqOVnjG1V08cUf/FPD80rSUXuEKevw4mciv3YM6xgYLkGSjumulEeBe321zsN3T
         j6BiDCs3gxGcxMhakfWwjafjlzoQ6akCglK1d/eKQKdpDGrotu7/d7xtpcuCO8k+GCQg
         7tRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f33si2016911eda.75.2019.04.03.23.51.33
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 23:51:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7094380D;
	Wed,  3 Apr 2019 23:51:32 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB6EF3F68F;
	Wed,  3 Apr 2019 23:51:26 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Steven Price <steven.price@arm.com>, Robin Murphy <robin.murphy@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mark.rutland@arm.com, mhocko@suse.com, david@redhat.com,
 logang@deltatee.com, cai@lca.pw, pasha.tatashin@oracle.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
 <e191ddcb-271c-57f3-091f-eacaac2e86e0@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c52f0adf-5764-19b8-235e-4c37148388aa@arm.com>
Date: Thu, 4 Apr 2019 12:21:28 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <e191ddcb-271c-57f3-091f-eacaac2e86e0@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 06:45 PM, Steven Price wrote:
> On 03/04/2019 13:37, Robin Murphy wrote:
>> [ +Steve ]
>>
>> Hi Anshuman,

Hi Steve,

>>
>> On 03/04/2019 05:30, Anshuman Khandual wrote:
> 
> <snip>
> 
>>> diff --git a/arch/arm64/include/asm/pgtable.h
>>> b/arch/arm64/include/asm/pgtable.h
>>> index de70c1e..858098e 100644
>>> --- a/arch/arm64/include/asm/pgtable.h
>>> +++ b/arch/arm64/include/asm/pgtable.h
>>> @@ -355,6 +355,18 @@ static inline int pmd_protnone(pmd_t pmd)
>>>   }
>>>   #endif
>>>   +#if (CONFIG_PGTABLE_LEVELS > 2)
>>> +#define pmd_large(pmd)    (pmd_val(pmd) && !(pmd_val(pmd) &
>>> PMD_TABLE_BIT))
>>> +#else
>>> +#define pmd_large(pmd) 0
>>> +#endif
>>> +
>>> +#if (CONFIG_PGTABLE_LEVELS > 3)
>>> +#define pud_large(pud)    (pud_val(pud) && !(pud_val(pud) &
>>> PUD_TABLE_BIT))
>>> +#else
>>> +#define pud_large(pmd) 0
>>> +#endif
>>
>> These seem rather different from the versions that Steve is proposing in
>> the generic pagewalk series - can you reach an agreement on which
>> implementation is preferred?
> 
> Indeed this doesn't match the version in my series although is quite
> similar.
> 
> My desire is that p?d_large represents the hardware architectural
> definition of large page/huge page/section (pick your naming). Although
> now I look more closely this is actually broken in my series (I'll fix
> that up and send a new version shortly) - p?d_sect() is similarly
> conditional.
> 
> Is there a good reason not to use the existing p?d_sect() macros
> available on arm64?

Nothing specific. Now I just tried using pud|pmd_sect() which looks good on
multiple configs for 4K/16K/64K. Will migrate pmd|pud_large() to more arch
specific pmd|pud_sect() which would also help in staying clear from your
series.

> 
> I'm also surprised by the CONFIG_PGTABLE_LEVEL conditions as they don't
> match the existing conditions for p?d_sect(). Might be worth double
> checking it actually does what you expect.

Right they are bit different. Surely will check. But if pmd|pud_sect() works
out okay will probably go with it as its been there for sometime.

