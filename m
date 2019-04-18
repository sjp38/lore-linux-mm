Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D22C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:08:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41AF0204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:08:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41AF0204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E42486B0005; Thu, 18 Apr 2019 02:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC89E6B0006; Thu, 18 Apr 2019 02:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6B986B0007; Thu, 18 Apr 2019 02:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7290A6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:08:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so665893edh.12
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:08:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=3YxIuVKrhGADmewzu9OJtP8RmCUzuapD7GRBk6NNZsw=;
        b=OTfCxfnUIm6X5QDlcDFIksFjfeSbvsYDHIFbHCtEtsKG3JC7gBfWb0/TKQXUV5aGrC
         f7qi0Fa+1O8ogP59MVlJovuydqzmh04YZslI23iCqJHs95AyIgYsWbDxHnDU/s5BjYXj
         qOXOCchC8v3CUiS/0LZ0LDzvLXYFwekZxMTWib5NorUQ4dwUQdBYWOU5ayCANlOINBhk
         n+NRA2wnhkl5rTJp652o+CAyyvqOTk+x2Ol/l1EarIs8y9eAJ+JSTHe8MJfYjcPBGwTR
         hI46RddePueUPTMXVrD2PN1wRir2fi4Jl3Ky32sQ6iJeE8Fc8M4ON/oXiqjLXTO9wbC3
         nRzA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW/Y+0l6+dP0d5W92RzWzrW/JJ2Ed0fkaAGOLwvrblgBvCScUbE
	Wb5cAnbLer/mH+3ZZmdXtspd3XDN8Fxh+4VGaceuRr1HQ09iw66S246A1kvmgMhLxCOWHBEIKki
	9nHd+NnEWUiumqeZFEfcja6mePNQJDQVJcSuV8CAPg1WFXQooT5dyRTNGnh64/L4=
X-Received: by 2002:aa7:c6c6:: with SMTP id b6mr57448495eds.69.1555567688035;
        Wed, 17 Apr 2019 23:08:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwL97AHlxSU4ETvZinrBLROuRpxoQOQI54nZRsNRnr0Rv94CWnSuolcm+JoK/8GDOAgzH02
X-Received: by 2002:aa7:c6c6:: with SMTP id b6mr57448455eds.69.1555567687311;
        Wed, 17 Apr 2019 23:08:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555567687; cv=none;
        d=google.com; s=arc-20160816;
        b=maPX51tw+SXJ37SkdgrkfY4JAflDVzyxf9jmCosb+iPc5XT7co720oYgNB2jvQmUKR
         c+nWwc6U4tHEzlP6f8T4Ec/eXIQ6U21m7SVLHGzdtfdgKSbgvYbrYiBz9HCldQGUtTAn
         vvjgEqSAguFEFveJf5rJTyMqRp6x2mIq1HwLtIQYBh4ItMMOjjnwKXsWlYfPRyBNC8X7
         We7JBvf/3YjjhlySqq8weH6D2bzimxnQxnvRqHqTYIK8BGQI/AjeARiHzgB7WoDw/xt1
         89QLWDd6RMUXm0FsreBpQGUKmkKlSDBxhEpP46q4O/xD4dY3zyD5ml1qko+OCPv2HYQG
         +9qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3YxIuVKrhGADmewzu9OJtP8RmCUzuapD7GRBk6NNZsw=;
        b=uHFKpPZYWpvNt7Uq1vbMfsJ/18sMe1WTwT+MU8uhadXky6Zj1ow/j881hqMjy45jm7
         Fh1//jj2vFs8OCVbuWe0dlq1tMVSvQKQWGAPhXuAUh+tMKP750p4IXcAc9PL8MXw6Mis
         NtI1G+W2FJLmj6TmIBcHqlFOyOx6VkDWLTmhW5NKIVO7TcYTYzOON7XGU7AIEt6HlyqV
         Ik5835Ef3Sg9UNLGFFM8MhqNuCQmL0+iAeeqDlBKiniQRmFX+H1YErCtPs/lA6//Muev
         gZIt7uY7PwRPMmurrc5Hd1Un+2V7OvSFz0LEAQUWUNb2BUOuDLvnUjaIeQn7JFH0uUB4
         1vsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id 17si596192ejy.390.2019.04.17.23.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 23:08:07 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id D89BD20008;
	Thu, 18 Apr 2019 06:08:02 +0000 (UTC)
Subject: Re: [PATCH v3 09/11] mips: Use STACK_TOP when computing mmap base
 address
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-10-alex@ghiti.fr>
 <CAGXu5jKx_A8GsFWWABKwEXmL5dTMKjk3Ub9GoE7Do9NcZ_ai=A@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <16ed1829-a7ad-76b9-2929-9eb14406da00@ghiti.fr>
Date: Thu, 18 Apr 2019 02:08:02 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKx_A8GsFWWABKwEXmL5dTMKjk3Ub9GoE7Do9NcZ_ai=A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/18/19 1:31 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:32 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> mmap base address must be computed wrt stack top address, using TASK_SIZE
>> is wrong since STACK_TOP and TASK_SIZE are not equivalent.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>


Thanks !


>
> -Kees
>
>> ---
>>   arch/mips/mm/mmap.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
>> index 3ff82c6f7e24..ffbe69f3a7d9 100644
>> --- a/arch/mips/mm/mmap.c
>> +++ b/arch/mips/mm/mmap.c
>> @@ -22,7 +22,7 @@ EXPORT_SYMBOL(shm_align_mask);
>>
>>   /* gap between mmap and stack */
>>   #define MIN_GAP                (128*1024*1024UL)
>> -#define MAX_GAP                ((TASK_SIZE)/6*5)
>> +#define MAX_GAP                ((STACK_TOP)/6*5)
>>   #define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>>
>>   static int mmap_is_legacy(struct rlimit *rlim_stack)
>> @@ -54,7 +54,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>>          else if (gap > MAX_GAP)
>>                  gap = MAX_GAP;
>>
>> -       return PAGE_ALIGN(TASK_SIZE - gap - rnd);
>> +       return PAGE_ALIGN(STACK_TOP - gap - rnd);
>>   }
>>
>>   #define COLOUR_ALIGN(addr, pgoff)                              \
>> --
>> 2.20.1
>>
>

