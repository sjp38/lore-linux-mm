Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBC2C6B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:46:55 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id a12so138433437ota.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:46:55 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id p65si8253700oig.161.2017.03.06.08.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 08:46:54 -0800 (PST)
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <fbc28b35-7ebe-5630-e8e2-76a77299fa89@virtuozzo.com>
Date: Mon, 6 Mar 2017 19:48:00 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Mark Rutland <mark.rutland@arm.com>

On 03/06/2017 05:24 PM, Dmitry Vyukov wrote:

> Let me provide more context and design alternatives.
> 
> There are also other archs, at least arm64 for now.
> There are also other tools. For KTSAN (race detector) we will
> absolutely need to hook into atomic ops. For KMSAN (uses of unit
> values) we also need to understand atomic ops at least to some degree.
> Both of them will require different instrumentation.
> For KASAN we are also more interested in cases where it's more likely
> that an object is touched only by an asm, but not by normal memory
> accesses (otherwise we would report the bug on the normal access,
> which is fine, this makes atomic ops stand out in my opinion).
> 
> We could involve compiler (and by compiler I mean clang, because we
> are not going to touch gcc, any volunteers?).

We've tried this with gcc about 3 years ago. Here is the patch - https://gcc.gnu.org/ml/gcc-patches/2014-05/msg02447.html
The problem is that memory block in "m" constraint doesn't actually mean
that inline asm will access it. It only means that asm block *may* access that memory (or part of it).
This causes false positives. As I vaguely remember I hit some false-positive in FPU-related code.

This problem gave birth to another idea - add a new constraint to strictly mark the memory access
inside asm block. See https://gcc.gnu.org/ml/gcc/2014-09/msg00237.html
But all ended with nothing.



> However, it's unclear if it will be simpler or not. There will
> definitely will be a problem with uaccess asm blocks. Currently KASAN
> relies of the fact that it does not see uaccess accesses and the user
> addresses are considered bad by KASAN. There can also be a problem
> with offsets/sizes, it's not possible to figure out what exactly an
> asm block touches, we can only assume that it directly dereferences
> the passed pointer. However, for example, bitops touch the pointer
> with offset. Looking at the current x86 impl, we should be able to
> handle it because the offset is computed outside of asm blocks. But
> it's unclear if we hit this problem in other places.
>
> I also see that arm64 bitops are implemented in .S files. And we won't
> be able to instrument them in compiler.
> There can also be other problems. Is it possible that some asm blocks
> accept e.g. physical addresses? KASAN would consider them as bad.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
