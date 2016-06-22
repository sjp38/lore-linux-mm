Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0BC828E1
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:53:54 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id x68so107412961ioi.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:53:54 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id p184si246794pfb.252.2016.06.22.07.53.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 07:53:53 -0700 (PDT)
Subject: Re: JITs and 52-bit VA
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
From: Christopher Covington <cov@codeaurora.org>
Message-ID: <576AA67E.50009@codeaurora.org>
Date: Wed, 22 Jun 2016 10:53:50 -0400
MIME-Version: 1.0
In-Reply-To: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>
Cc: Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>

+Andy, Cyrill, Dmitry who have been discussing variable TASK_SIZE on x86
on linux-mm

http://marc.info/?l=linux-mm&m=146290118818484&w=2

>>> On 04/28/2016 09:00 AM, Maxim Kuvyrkov wrote:
>>>> This is a summary of discussions we had on IRC between kernel and
>>>> toolchain engineers regarding support for JITs and 52-bit virtual
>>>> address space (mostly in the context of LuaJIT, but this concerns other
>>>> JITs too).
>>>> 
>>>> The summary is that we need to consider ways of reducing the size of
>>>> VA for a given process or container on a Linux system.
>>>> 
>>>> The high-level problem is that JITs tend to use upper bits of
>>>> addresses to encode various pieces of data, and that the number of
>>>> available bits is shrinking due to VA size increasing. With the usual
>>>> 42-bit VA (which is what most JITs assume) they have 22 bits to encode
>>>> various performance-critical data. With 48-bit VA (e.g., ThunderX world)
>>>> things start to get complicated, and JITs need to be non-trivially
>>>> patched at the source level to continue working with less bits available
>>>> for their performance-critical storage. With upcoming 52-bit VA things
>>>> might get dire enough for some JITs to declare such configurations
>>>> unsupported.
>>>> 
>>>> On the other hand, most JITs are not expected to requires terabytes
>>>> of RAM and huge VA for their applications. Most JIT applications will
>>>> happily live in 42-bit world with mere 4 terabytes of RAM that it
>>>> provides. Therefore, what JITs need in the modern world is a way to make
>>>> mmap() return addresses below a certain threshold, and error out with
>>>> ENOMEM when "lower" memory is exhausted. This is very similar to
>>>> ADDR_LIMIT_32BIT personality, but extended to common VA sizes on 64-bit
>>>> systems: 39-bit, 42-bit, 48-bit, 52-bit, etc.
>>>> 
>>>> Since we do not want to penalize the whole system (using an
>>>> artificially low-size VA), it would be best to have a way to enable VA
>>>> limit on per-process basis (similar to ADDR_LIMIT_32BIT personality). If
>>>> that's not possible -- then on per-container / cgroup basis. If that's
>>>> not possible -- then on system level (similar to vm.mmap_min_addr, but
>>>> from the other end).
>>>> 
>>>> Dear kernel people, what can be done to address the JITs need to
>>>> reduce effective VA size?

>> On 04/28/2016 09:17 AM, Arnd Bergmann wrote:
>>> Thanks for the summary, now it all makes much more sense.
>>> 
>>> One simple (from the kernel's perspective, not from the JIT) approach
>>> might be to always use MAP_FIXED whenever an allocation is made for
>>> memory that needs these special pointers, and then manage the available
>>> address space explicitly. Would that work, or do you require everything
>>> including the binary itself to be below the address?
>>> 
>>> Regarding which memory sizes are needed, my impression from your
>>> explanation is that a single personality flag (e.g. ADDR_LIMIT_42BIT)
>>> would be sufficient for the usecase, and you don't actually need to
>>> tie this to the architecture-provided virtual addressing limits
>>> at all. If it's only one such flag, we can probably find a way to fit
>>> it into the personality flags, though ironically we are actually
>>> running out of bits in there as well.

> On 04/28/2016 09:24 AM, Peter Maydell wrote:
>> The trouble IME with this idea is that in practice you're
>> linking with glibc, which means glibc is managing (and using)
>> the address space, not the JIT. So MAP_FIXED is pretty awkward
>> to use.

On 04/28/2016 03:27 PM, Steve Capper wrote:
> One can find holes in the VA space by examining /proc/self/maps, thus
> selection of pointers for MAP_FIXED can be deduced.
>
> The other problem is, as Arnd alluded to, if a JIT'ed object needs to
> then refer to something allocated outside of the JIT. This could be
> remedied by another level of indirection/trampoline.
>
> Taking two steps back though, I would view VA space squeezing as a
> stop-gap before removing tags from the upper bits of a pointer
> altogether (tagging the bottom bits, by controlling alignment is
> perfectly safe). The larger the VA space, the more scope mechanisms
> such as Address Space Layout Randomisation have to improve security.

I was working on an (AArch64-specific) auxiliary vector entry to export
TASK_SIZE to userspace at exec time. The goal was to allow for more
elegant, robust, and efficient replacements for the following changes:

https://hg.mozilla.org/integration/mozilla-inbound/rev/dfaafbaaa291

https://github.com/xemul/criu/commit/c0c0546c31e6df4932669f4740197bb830a24c8d

However based on the above discussion, it appears that some sort of
prctl(PR_GET_TASK_SIZE, ...) and prctl(PR_SET_TASK_SIZE, ...) may be
preferable for AArch64. (And perhaps other justifications for the new
calls influences the x86 decisions.) What do folks think?

Thanks,
Cov

-- 
Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
