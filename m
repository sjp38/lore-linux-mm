Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0526B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:36:00 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w4so914762pgq.15
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:36:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g11-v6si1855639plo.458.2018.02.21.08.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 08:35:59 -0800 (PST)
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D3B88217A9
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 16:35:58 +0000 (UTC)
Received: by mail-io0-f181.google.com with SMTP id n7so2776481iob.0
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 08:35:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <d636d1cb-88d9-8474-d5bc-fb2994108919@yandex-team.ru>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670492913.658225.2758351129158778856.stgit@buzz> <5c19630f-7466-676d-dbbc-a5668c91cbcd@yandex-team.ru>
 <20180220161634.517598ec63ec4a785c4c81cc@linux-foundation.org> <d636d1cb-88d9-8474-d5bc-fb2994108919@yandex-team.ru>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Feb 2018 16:35:37 +0000
Message-ID: <CALCETrXU5rq4HHvp2y0GZrvt85hRO=PEMakUQ938+mxF2xYwzw@mail.gmail.com>
Subject: Re: [PATCH 3/4] kernel/fork: switch vmapped stack callation to __vmalloc_area()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

On Wed, Feb 21, 2018 at 7:23 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
>
>
> On 21.02.2018 03:16, Andrew Morton wrote:
>>
>> On Tue, 23 Jan 2018 16:57:21 +0300 Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru> wrote:
>>
>>> # stress-ng --clone 100 -t 10s --metrics-brief
>>> at 32-core machine shows boost 35000 -> 36000 bogo ops
>>>
>>> Patch 4/4 is a kind of RFC.
>>> Actually per-cpu cache of preallocated stacks works faster than buddy
>>> allocator thus
>>> performance boots for it happens only at completely insane rate of
>>> clones.
>>>
>>
>> I'm not really sure what to make of this patchset.  Is it useful in any
>> known real-world use cases?
>
>
> Not yet. Feel free to ignore last patch.
>
>>
>>> +         This option neutralize stack overflow protection but allows to
>>> +         achieve best performance for syscalls fork() and clone().
>>
>>
>> That sounds problematic, but perhaps acceptable if the fallback only
>> happens rarely.
>>
>> Can this code be folded into CONFIG_VMAP_STACk in some cleaner fashion?
>> We now have options for non-vmapped stacks, vmapped stacks and a mix
>> of both.
>>
>> And what about this comment in arch/Kconfig:VMAP_STACK:
>>
>>            This is presently incompatible with KASAN because KASAN expects
>>            the stack to map directly to the KASAN shadow map using a
>> formula
>>            that is incorrect if the stack is in vmalloc space.
>>
>>
>> So VMAP_STACK_AS_FALLBACK will intermittently break KASAN?
>>
>
> All of this (including CONFIG_VMAP_STACK) could be turned into boot option.
> I think this would be a best solution.

Or someone could *fix* KASAN to work with stacks in the vmalloc area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
