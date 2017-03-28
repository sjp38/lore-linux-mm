Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF2512806CB
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:51:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r71so48789193wrb.17
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:51:55 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id f1si707669wrc.275.2017.03.28.02.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:51:54 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id p52so18051569wrc.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:51:54 -0700 (PDT)
Date: Tue, 28 Mar 2017 11:51:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170328095151.GC30567@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com>
 <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com>
 <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
 <20170328075232.GA19590@gmail.com>
 <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Mar 28, 2017 at 09:52:32AM +0200, Ingo Molnar wrote:
> 
> > No, regular C code.
> > 
> > I don't see the point of generating all this code via CPP - it's certainly not 
> > making it more readable to me. I.e. this patch I commented on is a step backwards 
> > for readability.
> 
> Note that much of the atomic stuff we have today is all CPP already.

Yeah, but there it's implementational: we pick up arch primitives depending on 
whether they are defined, such as:

#ifndef atomic_read_acquire
# define atomic_read_acquire(v)		smp_load_acquire(&(v)->counter)
#endif

> x86 is the exception because its 'weird', but most other archs are
> almost pure CPP -- check Alpha for example, or asm-generic/atomic.h.

include/asm-generic/atomic.h looks pretty clean and readable overall.

> Also, look at linux/atomic.h, its a giant maze of CPP.

Nah, that's OK, much of is is essentially __weak inlines implemented via CPP - 
i.e. CPP is filling in a missing compiler feature.

But this patch I replied to appears to add instrumentation wrappery via CPP which 
looks like excessive and avoidable obfuscation to me.

If it's much more readable and much more compact than the C version then maybe, 
but I'd like to see the C version first and see ...

> The CPP help us generate functions, reduces endless copy/paste (which induces 
> random differences -- read bugs) and construct variants depending on the 
> architecture input.
> 
> Yes, the CPP is a pain, but writing all that out explicitly is more of a
> pain.

So I'm not convinced that it's true in this case.

Could we see the C version and compare? I could be wrong about it all.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
