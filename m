Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3232E6B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 09:54:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s4so67382759pgr.3
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 06:54:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m37si1301610pla.977.2017.07.21.06.54.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 06:54:24 -0700 (PDT)
Date: Fri, 21 Jul 2017 15:54:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170721135420.gadjqv6hian4yzgq@hirez.programming.kicks-ass.net>
References: <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
 <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R>
 <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
 <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
 <CANrsvRMZ=i+L1sQzPiMVzpTOduNnTw_gKqcNkBVWPdpDs5fQZA@mail.gmail.com>
 <20170714064210.GK20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714064210.GK20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Fri, Jul 14, 2017 at 03:42:10PM +0900, Byungchul Park wrote:
> On Thu, Jul 13, 2017 at 08:23:33PM +0900, Byungchul Park wrote:
> > On Thu, Jul 13, 2017 at 8:12 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > On Thu, Jul 13, 2017 at 12:29:05PM +0200, Peter Zijlstra wrote:
> > >> On Thu, Jul 13, 2017 at 07:09:53PM +0900, Byungchul Park wrote:
> > >> > On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
> > >> > >   wait_for_completion(&C);
> > >> > >     atomic_inc_return();
> > >> > >
> > >> > >                                   mutex_lock(A1);
> > >> > >                                   mutex_unlock(A1);
> > >> > >
> > >> > >
> > >> > >                                   <IRQ>
> > >> > >                                     spin_lock(B1);
> > >> > >                                     spin_unlock(B1);
> > >> > >
> > >> > >                                     ...
> > >> > >
> > >> > >                                     spin_lock(B64);
> > >> > >                                     spin_unlock(B64);
> > >> > >                                   </IRQ>
> > >> > >
> > >> > >
> > >
> > > Also consider the alternative:
> > >
> > >                                         <IRQ>
> > >                                           spin_lock(D);
> > >                                           spin_unlock(D);
> > >
> > >                                           complete(&C);
> > >                                         </IRQ>
> > >
> > > in which case the context test will also not work.
> > 
> > Context tests are done on xhlock with the release context, _not_
> > acquisition context. For example, spin_lock(D) and complete(&C) are
> > in the same context, so the test would pass in this example.

The point was, this example will also link C to B*.

(/me copy paste from older email)

That gives:

        xhist[ 0] = A1
        xhist[ 1] = B1
        ...
        xhist[63] = B63

then we wrap and have:

        xhist[0] = B64

then we rewind to 1 and invalidate to arrive at:

        xhist[ 0] = B64
        xhist[ 1] = NULL   <-- idx
        xhist[ 2] = B2
        ...
        xhist[63] = B63


Then we do D and get

        xhist[ 0] = B64
        xhist[ 1] = D   <-- idx
        xhist[ 2] = B2
        ...
        xhist[63] = B63


And now there is nothing that will invalidate B*, after all, the
gen_id's are all after C's stamp, and the same_context_xhlock() test
will also pass because they're all from IRQ context (albeit not the
same, but it cannot tell).


Does this explain? Or am I still missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
