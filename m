Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B0C226B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:39:16 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n82so8226144oig.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:39:16 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 74si4096478oib.478.2017.10.09.11.39.15
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 11:39:15 -0700 (PDT)
Date: Mon, 9 Oct 2017 19:37:34 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/3] kcov: support comparison operands collection
Message-ID: <20171009183734.GA7784@leverpostej>
References: <20171009150521.82775-1-glider@google.com>
 <20171009154610.GA22534@leverpostej>
 <CACT4Y+Y_79MQVHg--92AJFk3_9XoLgaM2zF3zK5ErfnH-zNcPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y_79MQVHg--92AJFk3_9XoLgaM2zF3zK5ErfnH-zNcPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, andreyknvl <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 09, 2017 at 08:15:10PM +0200, 'Dmitry Vyukov' via syzkaller wrote:
> On Mon, Oct 9, 2017 at 5:46 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Mon, Oct 09, 2017 at 05:05:19PM +0200, Alexander Potapenko wrote:

> > ... I note that a few places in the kernel use a 128-bit type. Are
> > 128-bit comparisons not instrumented?
> 
> Yes, they are not instrumented.
> How many are there? Can you give some examples?

>From a quick scan, it doesn't looks like there are currently any
comparisons.

It's used as a data type in a few places under arm64:

arch/arm64/include/asm/checksum.h:      __uint128_t tmp;
arch/arm64/include/asm/checksum.h:      tmp = *(const __uint128_t *)iph;
arch/arm64/include/asm/fpsimd.h:                        __uint128_t vregs[32];
arch/arm64/include/uapi/asm/ptrace.h:   __uint128_t     vregs[32];
arch/arm64/include/uapi/asm/sigcontext.h:       __uint128_t vregs[32];
arch/arm64/kernel/signal32.c:   __uint128_t     raw;
arch/arm64/kvm/guest.c: __uint128_t tmp;

[...]

> >> +     area = t->kcov_area;
> >> +     /* The first 64-bit word is the number of subsequent PCs. */
> >> +     pos = READ_ONCE(area[0]) + 1;
> >> +     if (likely(pos < t->kcov_size)) {
> >> +             area[pos] = ip;
> >> +             WRITE_ONCE(area[0], pos);
> >
> > Not a new problem, but if the area for one thread is mmap'd, and read by
> > another thread, these two writes could be seen out-of-order, since we
> > don't have an smp_wmb() between them.
> >
> > I guess Syzkaller doesn't read the mmap'd kcov file from another thread?
> 
> 
> Yes, that's the intention. If you read coverage from another thread,
> you can't know coverage from what exactly you read. So the usage
> pattern is:
> 
> reset coverage;
> do something;
> read coverage;

Ok. I guess without a use-case for reading this from another thread it doesn't
really matter.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
