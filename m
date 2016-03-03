Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BD4036B0265
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:40:24 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 63so18511099pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 09:40:24 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id bx9si66897737pab.185.2016.03.03.09.40.24
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 09:40:24 -0800 (PST)
Date: Thu, 3 Mar 2016 17:40:15 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv2 0/3] KASAN: clean stale poison upon cold re-entry to
 kernel
Message-ID: <20160303174015.GG19139@leverpostej>
References: <1457024068-2236-1-git-send-email-mark.rutland@arm.com>
 <CAG_fn=WAfu4oD1Qb1xUnX765RpUznWm1y+FKYqqiM8VO53F+Ag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=WAfu4oD1Qb1xUnX765RpUznWm1y+FKYqqiM8VO53F+Ag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, mingo@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, catalin.marinas@arm.com, lorenzo.pieralisi@arm.com, peterz@infradead.org, will.deacon@arm.com, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi,

On Thu, Mar 03, 2016 at 06:17:31PM +0100, Alexander Potapenko wrote:
> Please replace "ASAN" with "KASAN".
> 
> On Thu, Mar 3, 2016 at 5:54 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > Functions which the compiler has instrumented for ASAN place poison on
> > the stack shadow upon entry and remove this poison prior to returning.
> >
> > In some cases (e.g. hotplug and idle), CPUs may exit the kernel a number
> > of levels deep in C code. If there are any instrumented functions on
> > this critical path, these will leave portions of the idle thread stack
> > shadow poisoned.
> >
> > If a CPU returns to the kernel via a different path (e.g. a cold entry),
> > then depending on stack frame layout subsequent calls to instrumented
> > functions may use regions of the stack with stale poison, resulting in
> > (spurious) KASAN splats to the console.
> >
> > Contemporary GCCs always add stack shadow poisoning when ASAN is
> > enabled, even when asked to not instrument a function [1], so we can't
> > simply annotate functions on the critical path to avoid poisoning.
> >
> > Instead, this series explicitly removes any stale poison before it can
> > be hit. In the common hotplug case we clear the entire stack shadow in
> > common code, before a CPU is brought online.
> >
> > On architectures which perform a cold return as part of cpu idle may
> > retain an architecture-specific amount of stack contents. To retain the
> > poison for this retained context, the arch code must call the core KASAN
> > code, passing a "watermark" stack pointer value beyond which shadow will
> > be cleared. Architectures which don't perform a cold return as part of
> > idle do not need any additional code.

For the above, and the rest of the series, ASAN consistently refers to
the compiler AddressSanitizer feature, and KASAN consistently refers to
the Linux-specific infrastructure. A simple s/[^K]ASAN/KASAN/ would
arguably be wrong (e.g. when referring to GCC behaviour above).

If there is a this needs rework, then I'm happy to s/[^K]ASAN/ASan/ to
follow the usual ASan naming convention and avoid confusion. Otherwise,
spinning a v3 is simply churn.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
