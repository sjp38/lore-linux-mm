Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1EEEE6B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 14:49:14 -0400 (EDT)
Received: by igcqo1 with SMTP id qo1so11812250igc.0
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 11:49:13 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id l16si1941627igf.0.2015.03.21.11.49.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Mar 2015 11:49:13 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so13059389igb.1
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 11:49:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550DAE23.7030000@oracle.com>
References: <550C37C9.2060200@oracle.com>
	<CA+55aFxoVPRuFJGuP_=0-NCiqx_NPeJBv+SAZqbAzeC9AhN+CA@mail.gmail.com>
	<550CA3F9.9040201@oracle.com>
	<550CB8D1.9030608@oracle.com>
	<CA+55aFwyuVWHMq_oc_hfwWcu6RaPGSifXD9-adX2_TOa-L+PHA@mail.gmail.com>
	<550DAE23.7030000@oracle.com>
Date: Sat, 21 Mar 2015 11:49:12 -0700
Message-ID: <CA+55aFwXmDom=GKE=K2QVqp_RUtOPQ0v5kCArATqQEKUOZ6OrA@mail.gmail.com>
Subject: Re: 4.0.0-rc4: panic in free_block
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Ahern <david.ahern@oracle.com>, David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Mar 21, 2015 at 10:45 AM, David Ahern <david.ahern@oracle.com> wrote:
>
> You raise a lot of valid questions and something to look into. But if the
> root cause were such a fundamental issue (CPU memory ordering, compiler bug,
> etc) why would it only occur on this one code path -- free with SLAB and
> NUMA -- and so consistently?

So the consistency could easily come from a compiler bug (or a missing
barrier in the kernel code) that just happens to trigger in a single
place (or in a few places, but then that's the only place that gets
exercised heavily enough to show it).

I agree that an actual hardware bug is unlikely, although that too is
possible: I can pretty much guarantee that if it were a CPU bug, it
wouldn't be some "memory ordering is entirely broken" bug in general,
it would be some very specific case that only happens with just the
right instruction timing and mix.

That said, while I bring up a CPU bug as a possibility, I really do
agree that it is *very* unlikely. Memory ordering is hard, and yes,
you can get it wrong, but at the same time CPU designers very much
know about it and tend to be pretty damn good about it. And as you
say, it generally wouldn't be *that* consistent. It might be
consistent for one particular kernel build (due to very particular
instruction mix and timings), but over lots of versions of the code
and many different debug options? Very very very unlikely.

> Continuing to poke around, but open to any suggestions. I have enabled every
> DEBUG I can find in the memory code and nothing is popping out. In terms of
> races wouldn't all the DEBUG checks affect timing? Yet, I am still seeing
> the same stack traces due to the same root cause.

Yes, generally debug options would change timings sufficiently that
any particular low-level race would certainly go away or at least
become much harder to hit. So if you have enabled spinlock debugging
etc, I don't really believe in a hw bug. It's  more likely that there
is some kernel architecture-specific code that triggers it. Or even
generic code that just happens to work on other cases due to random
issues (ie memory alignment etc).

I *would* suggest looking at that "memmove()" code. It really looks
like crap. It seems to do things byte-at-a-time for the overlapping
case, and the code seems to depend on memcpy always doing things
low-to-high, but there are multiple different memcpy implementations
so I don't know that that is always true. If one of the memcpy
functions sometimes copies the other way depending on size etc, it
could screw up.

Basically, that sparc64 memmove() implementation looks like it was
written by a dyslexic 5-year-old as a throw-away hack, and then never
got fixed.

Davem? I don't read sparc assembly, so I'm *really* not going to try
to verify that (a) all the memcpy implementations always copy
low-to-high and (b) that I even read the address comparisons in
memmove.S right.

I mention memmove just because it's actually fairly unusual for the
kernel. At the same time, if it really is broken for overlapping
regions, I'd expect *some* other places to show breakage too. So it's
probably fine, even if it does look very very bad to do things one
byte at a time backwards as a fallback.

                             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
