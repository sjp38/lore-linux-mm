Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57955C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:48:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C17720828
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:48:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C17720828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA31B8E0030; Thu, 25 Jul 2019 01:48:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B102C8E001C; Thu, 25 Jul 2019 01:48:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A56D8E0030; Thu, 25 Jul 2019 01:48:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 47C1F8E001C
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:48:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so31507515eda.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:48:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=hy5C7+tMYcPi6mDDZ2c8E8MjWGpi30cOGmtOOK8j0SQ=;
        b=A3nPxDONMHVCqN0AkzGGqfMpWrweHef/HusZq9PvISroYMCJnrTBqaCCKhkpF8rwve
         ujgY/UEbp/TPDovodG5RjfE9VcR8HJZnSrZKjHq7v+tm8Hyq6SxLcbUcFhe1A22YPWJr
         WblfvE0jd1R5c3YBIr2snaJK/GNzwCnvQsUtnlJnop8F7GjHsKhLNV/hm7aqGQqCcFRE
         2jhU63keMFQBrmKJyIfrqfqK055W8nz3/7P3MHPdBWd7ugEc6FGfeo+mN0BiCLTaVzr/
         D3rf/tb2PbV4NuRvaIl0BsHrz2KMTvZr0hwX5WYv/qGHSQGSD4URhQ00etFmql0OPNsV
         KEtA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXPo1Ro3wFTB9BWvzGoHFnSuHpq1vTf6foMO935AjoA8b/YEL/M
	gWh62A/tRZBwdKqqudy1BlTZPkav/WJRdPDc9wX4XiYrR+dykwYhCKIe0ancHiuadU/37ulYB2D
	Wt0SpRQHtmJOj2MH5J6xlC8VrLJeklIWlwKlZomhbPYFnOzN00TKCziNn23SFnLU=
X-Received: by 2002:a50:eb96:: with SMTP id y22mr74730778edr.211.1564033729824;
        Wed, 24 Jul 2019 22:48:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0ae7ZwnK1uUx2HmLllyHS9UCghE4P0Z3U9vIdEoOsLJx1Ky3LbMdHCCzIKzUbrN8tbfcy
X-Received: by 2002:a50:eb96:: with SMTP id y22mr74730756edr.211.1564033729178;
        Wed, 24 Jul 2019 22:48:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564033729; cv=none;
        d=google.com; s=arc-20160816;
        b=AUleQ6AQXxpytdYKEHwqhyLpFvyD93pBRMv84wFANHQMX786IsuoVaKVSmQqE5hbde
         x2njwesYm6lw1XAnokz+V24NgWvo4bWWU7VLvyGGJ0FLLsonjqxwJA4mU7BDGLv8aawv
         T4Kv9EvLQ0O/s1XMpk/qiGXI/bQTA9K74aQ00s6lgMYdQFylXqspB6OzGLkaHgPzYeCI
         tdL+0OMYmxbRqnnM6e6zPqbhRcMkoSpoSTijuGEDn/BcyTPNZf+Fpw737cgLWXSYNHTD
         qls4Vcp+RGmRTXFmC0drUqzvk2bDkP4jxp7/SB6Ohlw5mkQ2d8bA6r8inWe2EaL7lnqs
         fQUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hy5C7+tMYcPi6mDDZ2c8E8MjWGpi30cOGmtOOK8j0SQ=;
        b=YpL+HAYskKOtkGspsQ4mDUmLtWRaizdfBEaxCQmIkACvsGw2BAabZgpRRsVpc60X3S
         ifjgvg1yJfPIIAsUa+lS99rFFO5W7Ys9ATf6HKueH4kO4w2TeTb7Vv2LlEQQo8tKoWDV
         5Ppojzjnq7ng/IFk3DxxCW7F3mFBk4vnuPM3OXoql2f0iKUoMWoj5zLJywibS6rUecx/
         ygADoyhthNn9DVuQwXydOGE8s+Y9ubEgrFF3YjSknWjiJUorWCTMhpqkJ8U0cwoexTFG
         njEYVnRSmH3Haabqk9wwS1SP+FiAvm4ljZfFxzJH3Yv6zRLe4YWi6N4y74+wBpqvZjcw
         +cJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id 88si9637559edr.60.2019.07.24.22.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 22:48:49 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 83A0560002;
	Thu, 25 Jul 2019 05:48:44 +0000 (UTC)
Subject: Re: [PATCH REBASE v4 05/14] arm64, mm: Make randomization selected by
 generic topdown mmap layout
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, linux-riscv@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724055850.6232-6-alex@ghiti.fr>
 <20190724171123.GV19023@42.do-not-panic.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <8dd7b018-7f17-0018-0fcf-d0257976d275@ghiti.fr>
Date: Thu, 25 Jul 2019 07:48:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724171123.GV19023@42.do-not-panic.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000060, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 7:11 PM, Luis Chamberlain wrote:
> On Wed, Jul 24, 2019 at 01:58:41AM -0400, Alexandre Ghiti wrote:
>> diff --git a/mm/util.c b/mm/util.c
>> index 0781e5575cb3..16f1e56e2996 100644
>> --- a/mm/util.c
>> +++ b/mm/util.c
>> @@ -321,7 +321,15 @@ unsigned long randomize_stack_top(unsigned long stack_top)
>>   }
>>   
>>   #ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
>> -#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
>> +unsigned long arch_randomize_brk(struct mm_struct *mm)
>> +{
>> +	/* Is the current task 32bit ? */
>> +	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
>> +		return randomize_page(mm->brk, SZ_32M);
>> +
>> +	return randomize_page(mm->brk, SZ_1G);
>> +}
>> +
>>   unsigned long arch_mmap_rnd(void)
>>   {
>>   	unsigned long rnd;
>> @@ -335,7 +343,6 @@ unsigned long arch_mmap_rnd(void)
>>   
>>   	return rnd << PAGE_SHIFT;
>>   }
> So arch_randomize_brk is no longer ifdef'd around
> CONFIG_ARCH_HAS_ELF_RANDOMIZE either and yet the header
> still has it. Is that intentional?
>

Yes, CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT selects 
CONFIG_ARCH_HAS_ELF_RANDOMIZE, that's what's new about v4: the generic
functions proposed in this series come with elf randomization.


Alex


>    Luis
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

