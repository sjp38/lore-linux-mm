Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9F1B6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:20:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y77so154030460qkb.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:20:33 -0700 (PDT)
Received: from mail-vk0-x234.google.com (mail-vk0-x234.google.com. [2607:f8b0:400c:c05::234])
        by mx.google.com with ESMTPS id 92si899186uab.168.2016.06.22.12.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 12:20:33 -0700 (PDT)
Received: by mail-vk0-x234.google.com with SMTP id u64so75431003vkf.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:20:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160622191843.GA2045@uranus.lan>
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org> <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 22 Jun 2016 12:20:13 -0700
Message-ID: <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
Subject: Re: JITs and 52-bit VA
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On Wed, Jun 22, 2016 at 12:18 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Wed, Jun 22, 2016 at 08:13:29AM -0700, Andy Lutomirski wrote:
> ...
>> >
>> > However based on the above discussion, it appears that some sort of
>> > prctl(PR_GET_TASK_SIZE, ...) and prctl(PR_SET_TASK_SIZE, ...) may be
>> > preferable for AArch64. (And perhaps other justifications for the new
>> > calls influences the x86 decisions.) What do folks think?
>>
>> I would advocate a slightly different approach:
>>
>>  - Keep TASK_SIZE either unconditionally matching the hardware or keep
>> TASK_SIZE as the actual logical split between user and kernel
>> addresses.  Don't let it change at runtime under any circumstances.
>> The reason is that there have been plenty of bugs and
>> overcomplications that result from letting it vary.  For example, if
>> (addr < TASK_SIZE) really ought to be the correct check (assuming
>> USER_DS, anyway) for whether dereferencing addr will access user
>> memory, at least on architectures with a global address space (which
>> is most of them, I think).
>>
>>  - If needed, introduce a clean concept of the maximum address that
>> mmap will return, but don't call it TASK_SIZE.  So, if a user program
>> wants to limit itself to less than the full hardware VA space (or less
>> than 63 bits, for that matter), it can.
>>
>> As an example, a 32-bit x86 program really could have something mapped
>> above the 32-bit boundary.  It just wouldn't be useful, but the kernel
>> should still understand that it's *user* memory.
>>
>> So you'd have PR_SET_MMAP_LIMIT and PR_GET_MMAP_LIMIT or similar instead.
>
> +1. Also it might be (not sure though, just guessing) suitable to do such
> thing via memory cgroup controller, instead of carrying this limit per
> each process (or task structure/vma or mm).

I think we'll want this per mm.  After all, a high-VA-limit-aware bash
should be able run high-VA-unaware programs without fiddling with
cgroups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
