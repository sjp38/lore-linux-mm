Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EED06B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 02:30:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t187so100671780pfb.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 23:30:45 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n5si7825906pgk.175.2017.07.24.23.30.43
        for <linux-mm@kvack.org>;
        Mon, 24 Jul 2017 23:30:44 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:29:45 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170725062945.GM20323@X58A-UD3R>
References: <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
 <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R>
 <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
 <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
 <CANrsvRMZ=i+L1sQzPiMVzpTOduNnTw_gKqcNkBVWPdpDs5fQZA@mail.gmail.com>
 <20170714064210.GK20323@X58A-UD3R>
 <20170721135420.gadjqv6hian4yzgq@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170721135420.gadjqv6hian4yzgq@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Fri, Jul 21, 2017 at 03:54:20PM +0200, Peter Zijlstra wrote:
> On Fri, Jul 14, 2017 at 03:42:10PM +0900, Byungchul Park wrote:
> > On Thu, Jul 13, 2017 at 08:23:33PM +0900, Byungchul Park wrote:
> > > On Thu, Jul 13, 2017 at 8:12 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > > > On Thu, Jul 13, 2017 at 12:29:05PM +0200, Peter Zijlstra wrote:
> > > >> On Thu, Jul 13, 2017 at 07:09:53PM +0900, Byungchul Park wrote:
> > > >> > On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
> > > >> > >   wait_for_completion(&C);
> > > >> > >     atomic_inc_return();
> > > >> > >
> > > >> > >                                   mutex_lock(A1);
> > > >> > >                                   mutex_unlock(A1);
> > > >> > >
> > > >> > >
> > > >> > >                                   <IRQ>
> > > >> > >                                     spin_lock(B1);
> > > >> > >                                     spin_unlock(B1);
> > > >> > >
> > > >> > >                                     ...
> > > >> > >
> > > >> > >                                     spin_lock(B64);
> > > >> > >                                     spin_unlock(B64);
> > > >> > >                                   </IRQ>
> > > >> > >
> > > >> > >
> > > >
> > > > Also consider the alternative:
> > > >
> > > >                                         <IRQ>
> > > >                                           spin_lock(D);
> > > >                                           spin_unlock(D);
> > > >
> > > >                                           complete(&C);
> > > >                                         </IRQ>
> > > >
> > > > in which case the context test will also not work.
> > > 
> > > Context tests are done on xhlock with the release context, _not_
> > > acquisition context. For example, spin_lock(D) and complete(&C) are
> > > in the same context, so the test would pass in this example.
> 
> The point was, this example will also link C to B*.

_No_, as I already said.

> (/me copy paste from older email)
> 
> That gives:
> 
>         xhist[ 0] = A1
>         xhist[ 1] = B1
>         ...
>         xhist[63] = B63
> 
> then we wrap and have:
> 
>         xhist[0] = B64
> 
> then we rewind to 1 and invalidate to arrive at:

We invalidate xhist[_0_], as I already said.

>         xhist[ 0] = B64
>         xhist[ 1] = NULL   <-- idx
>         xhist[ 2] = B2
>         ...
>         xhist[63] = B63
> 
> 
> Then we do D and get
> 
>         xhist[ 0] = B64
>         xhist[ 1] = D   <-- idx
>         xhist[ 2] = B2
>         ...
>         xhist[63] = B63

We should get

         xhist[ 0] = NULL
         xhist[ 1] = D   <-- idx
         xhist[ 2] = B2
         ...
         xhist[63] = B63

By the way, did not you get my reply? I did exactly same answer.
Perhaps You have not received or read my replies.

> And now there is nothing that will invalidate B*, after all, the
> gen_id's are all after C's stamp, and the same_context_xhlock() test
> will also pass because they're all from IRQ context (albeit not the
> same, but it cannot tell).

It will stop at xhist[0] because it has been invalidated.

> Does this explain? Or am I still missing something?

Could you read the following reply? Not enough?

https://lkml.org/lkml/2017/7/13/214

I am sorry if my english makes you hard to understand. But I already
answered all you asked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
