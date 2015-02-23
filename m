Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 025506B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:02:05 -0500 (EST)
Received: by pabkq14 with SMTP id kq14so27065848pab.3
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:02:04 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id c1si1740386pdk.5.2015.02.23.04.02.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 04:02:04 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] kasan, module, vmalloc: rework shadow allocation for modules
In-Reply-To: <54E6E684.4070806@samsung.com>
References: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com> <87pp96stmz.fsf@rustcorp.com.au> <54E5E355.9020404@samsung.com> <87fva1sajo.fsf@rustcorp.com.au> <54E6E684.4070806@samsung.com>
Date: Mon, 23 Feb 2015 18:56:12 +1030
Message-ID: <87vbithw4b.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> On 02/20/2015 03:15 AM, Rusty Russell wrote:
>> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>>> On 02/19/2015 02:10 AM, Rusty Russell wrote:
>>>> This is not portable.  Other archs don't use vmalloc, or don't use
>>>> (or define) MODULES_VADDR.  If you really want to hook here, you'd
>>>> need a new flag (or maybe use PAGE_KERNEL_EXEC after an audit).
>>>>
>>>
>>> Well, instead of explicit (addr >= MODULES_VADDR && addr < MODULES_END)
>>> I could hide this into arch-specific function: 'kasan_need_to_allocate_shadow(const void *addr)'
>>> or make make all those functions weak and allow arch code to redefine them.
>> 
>> That adds another layer of indirection.  And how would the caller of
>> plain vmalloc() even know what to return?
>> 
>
> I think I don't understand what do you mean here. vmalloc() callers shouldn't know
> anything about kasan/shadow.

How else would kasan_need_to_allocate_shadow(const void *addr) work for
architectures which don't have a reserved vmalloc region for modules?

>> Hmm, how about a hybrid:
>> 
>> 1) Add kasan_module_alloc(p, size) after module alloc as your original.
>> 2) Hook into vfree(), and ignore it if you can't find the map.
>> 
>
> That should work, but it looks messy IMO.
>
>> Or is the latter too expensive?
>> 
>
> Not sure whether this will be too expensive or not,
> but definitely more expensive than simple (addr >= MODULES_VADDR && addr < MODULES_END) check.

Sure, if that check were portable.  If you ever wanted kasan on other
vmalloc addresses it wouldn't work either.

I actually think this pattern is the *simplest* solution for auxilliary
data like kasan.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
