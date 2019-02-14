Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6218FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:59:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B2FB222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:59:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B2FB222A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3F028E0002; Thu, 14 Feb 2019 05:59:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC8C98E0001; Thu, 14 Feb 2019 05:59:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 991F38E0002; Thu, 14 Feb 2019 05:59:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3248E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:59:28 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d9so2329997edl.16
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:59:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=OLGi4+bVgT+IBRSUTh+5UpvDZCcRO6jlzjyKTzE7H+U=;
        b=FO1GZGrRIeGWWtgfWBzHTcKmyUbYI4cZnQO/wOZrvk0Hou/ew//fpcZXLWa9Pfr/6S
         UQzD51R0wPwSlkJnCP2r1Jk9kdR3cw9TFoCAtUeI468gi1wOe7XCqu6y2y1J+beHBRRO
         NyWpU+m26Pqc77HVIdlraC77GPSDiVmwLvz9hXAmpPhEXWX8JYJDwbFuH2dvtaiSjfeg
         c3aPnWVwI1Q34EYht4SE2KXXPJcEdevoWMClmfnVYjahNrixRkJiXYom0/iyVfgCYtIn
         4ug/PfngjHJIHZlj9d+0PyJIcuHUxzfnT5TJuM/qmt8XTeRRXyheEUbCuYdgJiIxGOyz
         KmQQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: AHQUAub2FDpVk3AcA9mRgkrJ0FA07n0oMBnzaa+8FKyu1iLsCwgCfLXY
	y54m8pR5wtHaPsMjNb0cDSAyLPqabEqza6tYm/EUD7KCDHCh9tMm83Ds+SmA/j/Pre/nlUM2E2q
	0G4+rat4JRJcAfJFm9xsgKVcYlEVw8LoxvvrLOwTeT3Mot4hBO5FuPqtkC9phlo4=
X-Received: by 2002:a17:906:a94c:: with SMTP id hh12mr2372410ejb.168.1550141967775;
        Thu, 14 Feb 2019 02:59:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4SPjAAHFj0yzQyycMexMvV9sINdo2dKPiwi8Zey8qQ9j1SAqF9dllx4ddiG9ytJ1B7QK1
X-Received: by 2002:a17:906:a94c:: with SMTP id hh12mr2372365ejb.168.1550141966816;
        Thu, 14 Feb 2019 02:59:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550141966; cv=none;
        d=google.com; s=arc-20160816;
        b=kxFGQax5NeXxLwUNmfalW6OqJ0F2euk4wFidcwqr+HdZIciT9Nl71sfDciUZWEAXRB
         fGNJWWzXt6J7hSAcEM8NZU/vNxAZUSBkygjh/6jp8fpneN6DwP+aHFb11rU9l1P/5jf4
         1KgfPJn6YZbultLWe2hdXSUlnkqn6eVeKKBCHJCD0rx7aTpo29JQZiYcfH/Io7kPxzDk
         iytY5UIn8aG5LpHIobTfBHj4NafAQjcnFXLeL/sbg6VH44l7pWCtn1tVqTKcaL0jh/eT
         MCgXyaKMmRO1V4r/upkXeilhZUzS/vcNzFxsTyrSCPffMWOYyK9J7t/Dse1mNVgNvXb0
         DFvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=OLGi4+bVgT+IBRSUTh+5UpvDZCcRO6jlzjyKTzE7H+U=;
        b=ItcBdm7lCGkbuX6pC/1m/ycFQDXT+fJE8gAbDubNCFk7G+1cFWfRHmwIACBY3GNm4M
         MtEeTAAdKLeAabmuLDh3FPSn2d9PmUYBkwOEFzvglbvLRHanZGV2oO+SPcPa7K+sefIc
         ZZH2LWm5CLqdl33ReGkosg4/yjp2g8hT/LYPQ6nreJKqOMZik6n/sxSOZxs+28kFDEB6
         8ymWpikBC+895jOheL4z4tAWvIzfVDoFSlKHjbKcmrE+76cXF2KIIB96jnRF9ETtYgGD
         UcBrPsMPar6I34qjqR3SDv1XrbAzmKPMEH/F7sDk6k2ig5jTDrzHvmXL8LohYWTFToDy
         ePkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id o8si879676ejd.11.2019.02.14.02.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 02:59:26 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id 87261240005;
	Thu, 14 Feb 2019 10:59:18 +0000 (UTC)
Subject: Re: [PATCH v2] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@intel.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190213192610.17265-1-alex@ghiti.fr>
 <d367b5c7-eb05-6d0b-f9bf-5b3fc3f392a9@intel.com>
 <bcffa37e-22cd-f0d7-ee85-769c0d54520a@suse.cz>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <3f694efe-c8d4-d0b0-a3eb-127d1a6b0fd0@ghiti.fr>
Date: Thu, 14 Feb 2019 11:59:18 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <bcffa37e-22cd-f0d7-ee85-769c0d54520a@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/14/2019 10:52 AM, Vlastimil Babka wrote:
> On 2/13/19 8:30 PM, Dave Hansen wrote:
>>> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>>> +#ifdef CONFIG_COMPACTION_CORE
>>>   static __init int gigantic_pages_init(void)
>>>   {
>>>   	/* With compaction or CMA we can allocate gigantic pages at runtime */
>>> diff --git a/fs/Kconfig b/fs/Kconfig
>>> index ac474a61be37..8fecd3ea5563 100644
>>> --- a/fs/Kconfig
>>> +++ b/fs/Kconfig
>>> @@ -207,8 +207,9 @@ config HUGETLB_PAGE
>>>   config MEMFD_CREATE
>>>   	def_bool TMPFS || HUGETLBFS
>>>   
>>> -config ARCH_HAS_GIGANTIC_PAGE
>>> +config COMPACTION_CORE
>>>   	bool
>>> +	default y if (MEMORY_ISOLATION && MIGRATION) || CMA
>> This takes a hard dependency (#if) and turns it into a Kconfig *default*
>> that can be overridden.  That seems like trouble.
>>
>> Shouldn't it be:
>>
>> config COMPACTION_CORE
>> 	def_bool y
>> 	depends on (MEMORY_ISOLATION && MIGRATION) || CMA
> Agreed. Also I noticed that it now depends on MIGRATION instead of
> COMPACTION. That intention is correct IMHO, but will fail to
> compile/link when both COMPACTION and CMA are disabled, and would need
> more changes in mm/internal.h and mm/compaction.c (possibly just
> replacing CMA in all "if defined CONFIG_COMPACTION || defined
> CONFIG_CMA" instances with COMPACTION_CORE, but there might be more
> problems, wanna try? :)

Let's be honest, that's a "typo" :) Migration is logical to me but
that's because I don't know much about compaction. Thanks for
noticing it.
I'll take a look at what you propose to do too.

>
> Also, I realized that COMPACTION_CORE is a wrong name, sorry about that.
> What the config really provides is alloc_contig_range(), so it should be
> named either CONFIG_CMA_CORE (as it provides contiguous memory
> allocation, but not the related reservation and accounting), or
> something like CONFIG_CONTIG_ALLOC. I would also move it from fs/Kconfig
> to mm/Kconfig.

No problem, I was not inspired either. I'll send a v3 with the renaming
you propose.

> Thanks!

Thank you.

Alex

