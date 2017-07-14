Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE3EC4408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:43:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z10so78943768pff.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 23:43:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 1si5948852pgt.572.2017.07.13.23.43.01
        for <linux-mm@kvack.org>;
        Thu, 13 Jul 2017 23:43:01 -0700 (PDT)
Date: Fri, 14 Jul 2017 15:42:10 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170714064210.GK20323@X58A-UD3R>
References: <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
 <20170713020745.GG20323@X58A-UD3R>
 <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
 <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R>
 <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
 <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
 <CANrsvRMZ=i+L1sQzPiMVzpTOduNnTw_gKqcNkBVWPdpDs5fQZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANrsvRMZ=i+L1sQzPiMVzpTOduNnTw_gKqcNkBVWPdpDs5fQZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <max.byungchul.park@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Jul 13, 2017 at 08:23:33PM +0900, Byungchul Park wrote:
> On Thu, Jul 13, 2017 at 8:12 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Thu, Jul 13, 2017 at 12:29:05PM +0200, Peter Zijlstra wrote:
> >> On Thu, Jul 13, 2017 at 07:09:53PM +0900, Byungchul Park wrote:
> >> > On Thu, Jul 13, 2017 at 11:50:52AM +0200, Peter Zijlstra wrote:
> >> > >   wait_for_completion(&C);
> >> > >     atomic_inc_return();
> >> > >
> >> > >                                   mutex_lock(A1);
> >> > >                                   mutex_unlock(A1);
> >> > >
> >> > >
> >> > >                                   <IRQ>
> >> > >                                     spin_lock(B1);
> >> > >                                     spin_unlock(B1);
> >> > >
> >> > >                                     ...
> >> > >
> >> > >                                     spin_lock(B64);
> >> > >                                     spin_unlock(B64);
> >> > >                                   </IRQ>
> >> > >
> >> > >
> >
> > Also consider the alternative:
> >
> >                                         <IRQ>
> >                                           spin_lock(D);
> >                                           spin_unlock(D);
> >
> >                                           complete(&C);
> >                                         </IRQ>
> >
> > in which case the context test will also not work.
> 
> Context tests are done on xhlock with the release context, _not_
> acquisition context. For example, spin_lock(D) and complete(&C) are
> in the same context, so the test would pass in this example.

I think you got confused. Or do I?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
