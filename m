Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 055D36B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:16:49 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p66so19117201oia.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:16:49 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id b82si1098577oif.314.2017.06.28.03.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 03:16:48 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id c189so37705771oia.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:16:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
References: <cover.1498140838.git.dvyukov@google.com> <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
 <20170628100246.7nsvhblgi3xjbc4m@breakpoint.cc>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 28 Jun 2017 12:16:26 +0200
Message-ID: <CACT4Y+Yhy-jucOC37um5xZewEj0sdw8Hjte7oOYxDdxkzOTYoA@mail.gmail.com>
Subject: Re: [PATCH] locking/atomics: don't alias ____ptr
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 28, 2017 at 12:02 PM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> Trying to boot tip/master resulted in:
> |DMAR: dmar0: Using Queued invalidation
> |DMAR: dmar1: Using Queued invalidation
> |DMAR: Setting RMRR:
> |DMAR: Setting identity map for device 0000:00:1a.0 [0xbdcf9000 - 0xbdd1dfff]
> |BUG: unable to handle kernel NULL pointer dereference at           (null)
> |IP: __domain_mapping+0x10f/0x3d0
> |PGD 0
> |P4D 0
> |
> |Oops: 0002 [#1] PREEMPT SMP
> |Modules linked in:
> |CPU: 19 PID: 1 Comm: swapper/0 Not tainted 4.12.0-rc6-00117-g235a93822a21 #113
> |task: ffff8805271c2c80 task.stack: ffffc90000058000
> |RIP: 0010:__domain_mapping+0x10f/0x3d0
> |RSP: 0000:ffffc9000005bca0 EFLAGS: 00010246
> |RAX: 0000000000000000 RBX: 00000000bdcf9003 RCX: 0000000000000000
> |RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000001
> |RBP: ffffc9000005bd00 R08: ffff880a243e9780 R09: ffff8805259e67c8
> |R10: 00000000000bdcf9 R11: 0000000000000000 R12: 0000000000000025
> |R13: 0000000000000025 R14: 0000000000000000 R15: 00000000000bdcf9
> |FS:  0000000000000000(0000) GS:ffff88052acc0000(0000) knlGS:0000000000000000
> |CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> |CR2: 0000000000000000 CR3: 0000000001c0f000 CR4: 00000000000406e0
> |Call Trace:
> | iommu_domain_identity_map+0x5a/0x80
> | domain_prepare_identity_map+0x9f/0x160
> | iommu_prepare_identity_map+0x7e/0x9b
>
> bisect points to commit 235a93822a21 ("locking/atomics, asm-generic: Add KASAN
> instrumentation to atomic operations"), RIP is at
>          tmp = cmpxchg64_local(&pte->val, 0ULL, pteval);
> in drivers/iommu/intel-iommu.c. The assembly for this inline assembly
> is:
>     xor    %edx,%edx
>     xor    %eax,%eax
>     cmpxchg %rbx,(%rdx)
>
> and as you see edx is set to zero and used later as a pointer via the
> full register. This happens with gcc-6, 5 and 8 (snapshot from last
> week).
> After a longer while of searching and swearing I figured out that this
> bug occures once cmpxchg64_local() and cmpxchg_local() uses the same
> ____ptr macro and they are shadow somehow. What I don't know why edx is
> set to zero.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  include/asm-generic/atomic-instrumented.h | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
> index a0f5b7525bb2..ac6155362b39 100644
> --- a/include/asm-generic/atomic-instrumented.h
> +++ b/include/asm-generic/atomic-instrumented.h
> @@ -359,16 +359,16 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
>
>  #define cmpxchg64(ptr, old, new)                       \
>  ({                                                     \
> -       __typeof__(ptr) ____ptr = (ptr);                \
> -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> -       arch_cmpxchg64(____ptr, (old), (new));          \
> +       __typeof__(ptr) ____ptr64 = (ptr);              \
> +       kasan_check_write(____ptr64, sizeof(*____ptr64));\
> +       arch_cmpxchg64(____ptr64, (old), (new));        \
>  })
>
>  #define cmpxchg64_local(ptr, old, new)                 \
>  ({                                                     \
> -       __typeof__(ptr) ____ptr = (ptr);                \
> -       kasan_check_write(____ptr, sizeof(*____ptr));   \
> -       arch_cmpxchg64_local(____ptr, (old), (new));    \
> +       __typeof__(ptr) ____ptr64 = (ptr);              \
> +       kasan_check_write(____ptr64, sizeof(*____ptr64));\
> +       arch_cmpxchg64_local(____ptr64, (old), (new));  \
>  })
>
>  #define cmpxchg_double(p1, p2, o1, o2, n1, n2)                         \


Doh! Thanks for fixing this. I think I've a similar crash in a
different place when I developed the patch.
The problem is that when we do:

       __typeof__(ptr) ____ptr = (ptr);                \
       arch_cmpxchg64_local(____ptr, (old), (new));    \

We don't necessary pass value of our just declared ____ptr to
arch_cmpxchg64_local(). We just pass a symbolic identifier. So if
arch_cmpxchg64_local() declares own ____ptr and then tries to use what
we passed ("____ptr") it will actually refer to own variable declared
rather than to what we wanted to pass in.

In my case I ended up with something like:

__typeof__(foo) __ptr = __ptr;

which compiler decided to turn into 0.

Thank you, macros.

We can add more underscores, but the problem can happen again. Should
we prefix current function/macro name to all local vars?..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
