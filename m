Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74D5D828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:21:35 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g127so146125972ith.3
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 01:21:35 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0102.outbound.protection.outlook.com. [104.47.0.102])
        by mx.google.com with ESMTPS id f71si5370908oig.189.2016.06.23.01.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 01:21:34 -0700 (PDT)
Subject: Re: JITs and 52-bit VA
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <8a39cb56-e584-5998-bc2e-78c8b8c24211@virtuozzo.com>
Date: Thu, 23 Jun 2016 11:20:19 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Christopher Covington <cov@codeaurora.org>
Cc: Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On 06/22/2016 06:13 PM, Andy Lutomirski wrote:
> On Wed, Jun 22, 2016 at 7:53 AM, Christopher Covington
> <cov@codeaurora.org> wrote:
>> +Andy, Cyrill, Dmitry who have been discussing variable TASK_SIZE on x86
>> on linux-mm
>>
>> http://marc.info/?l=linux-mm&m=146290118818484&w=2
>>
>>
>> I was working on an (AArch64-specific) auxiliary vector entry to export
>> TASK_SIZE to userspace at exec time. The goal was to allow for more
>> elegant, robust, and efficient replacements for the following changes:
>>
>> https://hg.mozilla.org/integration/mozilla-inbound/rev/dfaafbaaa291
>>
>> https://github.com/xemul/criu/commit/c0c0546c31e6df4932669f4740197bb830a24c8d
>>
>> However based on the above discussion, it appears that some sort of
>> prctl(PR_GET_TASK_SIZE, ...) and prctl(PR_SET_TASK_SIZE, ...) may be
>> preferable for AArch64. (And perhaps other justifications for the new
>> calls influences the x86 decisions.) What do folks think?
>
> I would advocate a slightly different approach:
>
>  - Keep TASK_SIZE either unconditionally matching the hardware or keep
> TASK_SIZE as the actual logical split between user and kernel
> addresses.  Don't let it change at runtime under any circumstances.
> The reason is that there have been plenty of bugs and
> overcomplications that result from letting it vary.  For example, if
> (addr < TASK_SIZE) really ought to be the correct check (assuming
> USER_DS, anyway) for whether dereferencing addr will access user
> memory, at least on architectures with a global address space (which
> is most of them, I think).
>
>  - If needed, introduce a clean concept of the maximum address that
> mmap will return, but don't call it TASK_SIZE.  So, if a user program
> wants to limit itself to less than the full hardware VA space (or less
> than 63 bits, for that matter), it can.
>
> As an example, a 32-bit x86 program really could have something mapped
> above the 32-bit boundary.  It just wouldn't be useful, but the kernel
> should still understand that it's *user* memory.
>
> So you'd have PR_SET_MMAP_LIMIT and PR_GET_MMAP_LIMIT or similar instead.

I like to agree -- this approach seems clear.
It also complements your idea of unifying TASK_SIZE for x86 and leaving
only ADDR_LIMIT_32BIT setting with personality()


> Also, before getting *too* excited about this kind of VA limit, keep
> in mind that SPARC has invented this thingly called "Application Data
> Integrity".

Thanks for the link -- what a good thing. I dream it could work not on
per-page basis, heh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
