Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B9BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66FBD218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66FBD218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBD178E0003; Thu, 28 Feb 2019 04:22:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6CB28E0001; Thu, 28 Feb 2019 04:22:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0F698E0003; Thu, 28 Feb 2019 04:22:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2398E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:22:40 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id j26so1237201lfb.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:22:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5b363oXSvx3xENgCoRgWlXjOSb6+dTblZ80xbnz9n1s=;
        b=JRV3vz/Nak+bRRENh0NA0CCUKinqsk5h/jJeHevrv/juaEjSk7J9qg9mPEZ7xHhbwc
         +S9siKHLu675gowFaMQlOG0/ftxNL7tuTCAFZ0FhWCWJ2rM7J++E9WZzzgUn13wsGfYS
         N1q1HvWB8lr1ekeNAthGiFFcDUxdoEugaFIOWSnCaI6ttH76KdEkGrPKWVV1oygD38fd
         ZzV78sVrk/O7/FKb55/bJKn2C7o5vPOFtlIbvoBCueJ+R/4B4ur0woX7LP+NRidfD4m2
         NWlUWOyqEc80FNfoeZn0TkSTJkYawruV9EV6G2BoJez9B0maI3FnMfDIsogwLvNv0n1J
         rpRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuasAqia8NzkarUUxzMZK80y6ciHvo6WATBrdn0vDr64BE5er+VS
	TodsIYgjBukMj3hgqt1R0pofJksF74/lfaWtUHcwbCOqk9134d3LbLX1xbUfFGjLk5/Ul0bEUd2
	FA5HfF81QikLDRTdOGobzro0319jAJyFZAzoX3wmvDVBZi9t1j6jCMzL3b4mpRtAUFg==
X-Received: by 2002:a2e:b001:: with SMTP id y1mr4033469ljk.130.1551345759750;
        Thu, 28 Feb 2019 01:22:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLLn1UnrF9RBYOthU1nigUGa6ZrwBnetxhwYiiM04/eqti3EWo2jHG+GDaFAPk3gCOeEHY
X-Received: by 2002:a2e:b001:: with SMTP id y1mr4033410ljk.130.1551345758457;
        Thu, 28 Feb 2019 01:22:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551345758; cv=none;
        d=google.com; s=arc-20160816;
        b=O0Ps0DVF7nBEKlG69ZOLN3Gf3DdNSVaLDHTw9oHUwKMhX7w9ARkxfZO7F890ZyI+2j
         P/qWojneYJ64GvvBH1jODBcraiNqg2wiIkO2t+vgAHkQo+a2PrgM3NGpdtegMxpDZ7tx
         FP9vYgVZbKofMxqbSfCXD7ciSM59unzwRFoEgmzI/YVWlu5CK2ETLYKOQHK/Vzv9Rfsk
         +jksNQqI10lmhqHDZIgZsJ94eGnKEfYz24VYkGVzN6L4r1IANRCZvaiO+4UEBp5TBsgR
         VYkiFW+H8utldy8MXuCKeCImDEN8ut/SrXWc0XB7hQ1fgAjKhRVg8n6+npVNjGxiCA7L
         H7bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5b363oXSvx3xENgCoRgWlXjOSb6+dTblZ80xbnz9n1s=;
        b=QiOPXbf3II69ZBH4CtEUYiL/ve9NDFMDDTUQshMJDr0gZo5clQvdWLyl3v5trMzTgZ
         U8GjimhUz2OeG6I9XvSlEac9BjVx7RwzlG87djSSxWQPKM5F5BNL2AO3Dwop6eljTGx8
         HdSbG3slZFV0EmYiolaK2D0vPWKFVjHuKjyyHLaSkob7on9Il57MpA69kEfhreX8Jz0K
         u1zTCc9FGwRFysCJot42CVlfvwCLLPJ2FT6NmYXrn7mEx+Y0ZWG7MC8CekiiRy5SRrgp
         MeAZnIBwG0ugWJ8i55O1PHroOoQbQ5ch01PYLXGbFfgxchI8XpzNwkng7kKLfVW03cu2
         foVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id a4si13606519ljf.7.2019.02.28.01.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:22:38 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzHtj-0001bs-SS; Thu, 28 Feb 2019 12:22:35 +0300
Subject: Re: BUG: KASAN: stack-out-of-bounds
To: Christophe Leroy <christophe.leroy@c-s.fr>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Daniel Axtens <dja@axtens.net>, linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com
References: <c6d80735-0cfe-b4ab-0349-673fc65b2e15@c-s.fr>
 <5f0203bd-77ea-d94c-11b7-1befba439cd4@virtuozzo.com>
 <15a40476-2852-cf5a-0982-d899dd79d9c1@c-s.fr>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <7778f728-3ca2-7ad6-503f-72ca098863cb@virtuozzo.com>
Date: Thu, 28 Feb 2019 12:22:53 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <15a40476-2852-cf5a-0982-d899dd79d9c1@c-s.fr>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/27/19 4:11 PM, Christophe Leroy wrote:
> 
> 
> Le 27/02/2019 à 10:19, Andrey Ryabinin a écrit :
>>
>>
>> On 2/27/19 11:25 AM, Christophe Leroy wrote:
>>> With version v8 of the series implementing KASAN on 32 bits powerpc (https://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=94309), I'm now able to activate KASAN on a mac99 is QEMU.
>>>
>>> Then I get the following reports at startup. Which of the two reports I get seems to depend on the option used to build the kernel, but for a given kernel I always get the same report.
>>>
>>> Is that a real bug, in which case how could I spot it ? Or is it something wrong in my implementation of KASAN ?
>>>
>>> I checked that after kasan_init(), the entire shadow memory is full of 0 only.
>>>
>>> I also made a try with the strong STACK_PROTECTOR compiled in, but no difference and nothing detected by the stack protector.
>>>
>>> ==================================================================
>>> BUG: KASAN: stack-out-of-bounds in memchr+0x24/0x74
>>> Read of size 1 at addr c0ecdd40 by task swapper/0
>>>
>>> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1133
>>> Call Trace:
>>> [c0e9dca0] [c01c42a0] print_address_description+0x64/0x2bc (unreliable)
>>> [c0e9dcd0] [c01c4684] kasan_report+0xfc/0x180
>>> [c0e9dd10] [c089579c] memchr+0x24/0x74
>>> [c0e9dd30] [c00a9e38] msg_print_text+0x124/0x574
>>> [c0e9dde0] [c00ab710] console_unlock+0x114/0x4f8
>>> [c0e9de40] [c00adc60] vprintk_emit+0x188/0x1c4
>>> --- interrupt: c0e9df00 at 0x400f330
>>>      LR = init_stack+0x1f00/0x2000
>>> [c0e9de80] [c00ae3c4] printk+0xa8/0xcc (unreliable)
>>> [c0e9df20] [c0c28e44] early_irq_init+0x38/0x108
>>> [c0e9df50] [c0c16434] start_kernel+0x310/0x488
>>> [c0e9dff0] [00003484] 0x3484
>>>
>>> The buggy address belongs to the variable:
>>>   __log_buf+0xec0/0x4020
>>> The buggy address belongs to the page:
>>> page:c6eac9a0 count:1 mapcount:0 mapping:00000000 index:0x0
>>> flags: 0x1000(reserved)
>>> raw: 00001000 c6eac9a4 c6eac9a4 00000000 00000000 00000000 ffffffff 00000001
>>> page dumped because: kasan: bad access detected
>>>
>>> Memory state around the buggy address:
>>>   c0ecdc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>   c0ecdc80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>>> c0ecdd00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
>>>                                     ^
>>>   c0ecdd80: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>>>   c0ecde00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>> ==================================================================
>>>
>>
>> This one doesn't look good. Notice that it says stack-out-of-bounds, but at the same time there is
>>     "The buggy address belongs to the variable:  __log_buf+0xec0/0x4020"
>>   which is printed by following code:
>>     if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
>>         pr_err("The buggy address belongs to the variable:\n");
>>         pr_err(" %pS\n", addr);
>>     }
>>
>> So the stack unrelated address got stack-related poisoning. This could be a stack overflow, did you increase THREAD_SHIFT?
>> KASAN with stack instrumentation significantly increases stack usage.
>>
> 
> I get the above with THREAD_SHIFT set to 13 (default value).
> If increasing it to 14, I get the following instead. That means that in that case the problem arises a lot earlier in the boot process (but still after the final kasan shadow setup).
> 

We usually use 15 (with 4k pages), but I think 14 should be enough for the clean boot.

> ==================================================================
> BUG: KASAN: stack-out-of-bounds in pmac_nvram_init+0x1f8/0x5d0
> Read of size 1 at addr f6f37de0 by task swapper/0
> 
> CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc7+ #1143
> Call Trace:
> [c0e9fd60] [c01c43c0] print_address_description+0x164/0x2bc (unreliable)
> [c0e9fd90] [c01c46a4] kasan_report+0xfc/0x180
> [c0e9fdd0] [c0c226d4] pmac_nvram_init+0x1f8/0x5d0
> [c0e9fef0] [c0c1f73c] pmac_setup_arch+0x298/0x314
> [c0e9ff20] [c0c1ac40] setup_arch+0x250/0x268
> [c0e9ff50] [c0c151dc] start_kernel+0xb8/0x488
> [c0e9fff0] [00003484] 0x3484
> 
> 
> Memory state around the buggy address:
>  f6f37c80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  f6f37d00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>>f6f37d80: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
>                                                ^
>  f6f37e00: 00 00 01 f4 f2 f2 f2 f2 00 00 00 00 f2 f2 f2 f2
>  f6f37e80: 00 00 00 00 f3 f3 f3 f3 00 00 00 00 00 00 00 00
> ==================================================================

Powerpc's show_stack() prints stack addresses, so we know that stack is something near 0xc0e9f... address.
f6f37de0 is definitely not stack address and it's to far for the stack overflow.
So it looks like shadow for stack  - kasan_mem_to_shadow(0xc0e9f...) and shadow for address in report - kasan_mem_to_shadow(0xf6f37de0)
point to the same physical page. 

