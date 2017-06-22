Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2A16B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 04:25:06 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so2527392wrb.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 01:25:06 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id s17si860466wra.76.2017.06.22.01.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 01:25:04 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id z45so2745069wrb.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 01:25:04 -0700 (PDT)
Date: Thu, 22 Jun 2017 10:25:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 5/7] kasan: allow kasan_check_read/write() to accept
 pointers to volatiles
Message-ID: <20170622082501.5q66ucborgxdxqzg@gmail.com>
References: <cover.1497690003.git.dvyukov@google.com>
 <e5a4c25bda8eccce2317da6d97138bfbea730e64.1497690003.git.dvyukov@google.com>
 <20170619105008.GD10246@leverpostej>
 <CACT4Y+Zc1EzTLq+cAf2hg8s4CynJdWVc_9sOROkRs9+XU3AXPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zc1EzTLq+cAf2hg8s4CynJdWVc_9sOROkRs9+XU3AXPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Dmitry Vyukov <dvyukov@google.com> wrote:

> On Mon, Jun 19, 2017 at 12:50 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Sat, Jun 17, 2017 at 11:15:31AM +0200, Dmitry Vyukov wrote:
> >> Currently kasan_check_read/write() accept 'const void*', make them
> >> accept 'const volatile void*'. This is required for instrumentation
> >> of atomic operations and there is just no reason to not allow that.
> >>
> >> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> >> Cc: Mark Rutland <mark.rutland@arm.com>
> >> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> Cc: Thomas Gleixner <tglx@linutronix.de>
> >> Cc: "H. Peter Anvin" <hpa@zytor.com>
> >> Cc: Peter Zijlstra <peterz@infradead.org>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: linux-kernel@vger.kernel.org
> >> Cc: x86@kernel.org
> >> Cc: linux-mm@kvack.org
> >> Cc: kasan-dev@googlegroups.com
> >
> > Looks sane to me, and I can confirm this doesn't advervsely affect
> > arm64. FWIW:
> >
> > Acked-by: Mark Rutland <mark.rutland@arm.com>
> >
> > Mark.
> 
> 
> Great! Thanks for testing.
> 
> Ingo, what are your thoughts? Are you taking this to locking tree? When?

Yeah, it all looks pretty clean to me too. I've applied the first three patches to 
the locking tree, but did some minor stylistic cleanups to the first patch to 
harmonize the style of the code - which made the later patches not apply cleanly.

Mind sending the remaining patches against the locking tree, tip:locking/core? 
(Please also add in all the acks you got.)

This should also give people (Peter, Linus?) a last minute chance to object to my 
suggestion of increasing the linecount in patch #1:

 0f2376eb0ff8: locking/atomic/x86: Un-macro-ify atomic ops implementation

 arch/x86/include/asm/atomic.h      | 69 ++++++++++++++++++++++++++++++++++++++++++++++-----------------------
 arch/x86/include/asm/atomic64_32.h | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------
 arch/x86/include/asm/atomic64_64.h | 67 ++++++++++++++++++++++++++++++++++++++++++++-----------------------
 3 files changed, 147 insertions(+), 70 deletions(-)

... to me the end result looks much more readable despite the +70 lines of code, 
but if anyone feels strongly about this please holler!

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
