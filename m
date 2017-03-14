Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35B5F6B038D
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:25:54 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id r136so46657091vke.6
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:25:54 -0700 (PDT)
Received: from mail-ua0-x232.google.com (mail-ua0-x232.google.com. [2607:f8b0:400c:c08::232])
        by mx.google.com with ESMTPS id q66si1506308vkd.247.2017.03.14.12.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 12:25:53 -0700 (PDT)
Received: by mail-ua0-x232.google.com with SMTP id 72so175707733uaf.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:25:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170314154429.GB15740@leverpostej>
References: <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net> <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej> <20170306203500.GR6500@twins.programming.kicks-ass.net>
 <CACT4Y+ZNb_eCLVBz6cUyr0jVPdSW_-nCedcBAh0anfds91B2vw@mail.gmail.com>
 <20170308152027.GA13133@leverpostej> <20170308174300.GL20400@arm.com>
 <CACT4Y+bjMLgXHv0Wwuo1fnEWitxfdJLdH2oCy+rSa2kTjNXmuw@mail.gmail.com>
 <20170314153230.GR5680@worktop> <20170314154429.GB15740@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 14 Mar 2017 20:25:32 +0100
Message-ID: <CACT4Y+Zx-fT+FSWm9B8=E9GH6KLoAL0ATDcU9MbBkwBC9+5qqQ@mail.gmail.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Mar 14, 2017 at 4:44 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>> > -static __always_inline int atomic_read(const atomic_t *v)
>> > +static __always_inline int arch_atomic_read(const atomic_t *v)
>> >  {
>> > -   return READ_ONCE((v)->counter);
>> > +   return READ_ONCE_NOCHECK((v)->counter);
>>
>> Should NOCHEKC come with a comment, because i've no idea why this is so.
>
> I suspect the idea is that given the wrapper will have done the KASAN
> check, duplicating it here is either sub-optimal, or results in
> duplicate splats. READ_ONCE() has an implicit KASAN check,
> READ_ONCE_NOCHECK() does not.
>
> If this is to solve duplicate splats, it'd be worth having a
> WRITE_ONCE_NOCHECK() for arch_atomic_set().
>
> Agreed on the comment, regardless.


Reverted xchg changes.
Added comments re READ_ONCE_NOCHECK() and WRITE_ONCE().
Added file comment.
Split into 3 patches and mailed.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
