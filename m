Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2A436B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 04:45:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 72so73700400pfl.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 01:45:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 17si7200350pft.341.2017.07.25.01.45.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 01:45:24 -0700 (PDT)
Date: Tue, 25 Jul 2017 10:45:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170725084521.hazqpckbpg4rrucf@hirez.programming.kicks-ass.net>
References: <20170713081442.GA439@worktop>
 <20170713085746.GH20323@X58A-UD3R>
 <20170713095052.dssev34f7c43vlok@hirez.programming.kicks-ass.net>
 <20170713100953.GI20323@X58A-UD3R>
 <20170713102905.ysrvn7td6ryt4jaj@hirez.programming.kicks-ass.net>
 <20170713111209.ji6w3trt45icpuf6@hirez.programming.kicks-ass.net>
 <CANrsvRMZ=i+L1sQzPiMVzpTOduNnTw_gKqcNkBVWPdpDs5fQZA@mail.gmail.com>
 <20170714064210.GK20323@X58A-UD3R>
 <20170721135420.gadjqv6hian4yzgq@hirez.programming.kicks-ass.net>
 <20170725062945.GM20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725062945.GM20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, boqun.feng@gmail.com, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Jul 25, 2017 at 03:29:45PM +0900, Byungchul Park wrote:

> _No_, as I already said.
> 
> > (/me copy paste from older email)
> > 
> > That gives:
> > 
> >         xhist[ 0] = A1
> >         xhist[ 1] = B1
> >         ...
> >         xhist[63] = B63
> > 
> > then we wrap and have:
> > 
> >         xhist[0] = B64
> > 
> > then we rewind to 1 and invalidate to arrive at:
> 
> We invalidate xhist[_0_], as I already said.
> 
> >         xhist[ 0] = B64
> >         xhist[ 1] = NULL   <-- idx
> >         xhist[ 2] = B2
> >         ...
> >         xhist[63] = B63
> > 
> > 
> > Then we do D and get
> > 
> >         xhist[ 0] = B64
> >         xhist[ 1] = D   <-- idx
> >         xhist[ 2] = B2
> >         ...
> >         xhist[63] = B63
> 
> We should get
> 
>          xhist[ 0] = NULL
>          xhist[ 1] = D   <-- idx
>          xhist[ 2] = B2
>          ...
>          xhist[63] = B63
> 
> By the way, did not you get my reply? I did exactly same answer.
> Perhaps You have not received or read my replies.
> 
> > And now there is nothing that will invalidate B*, after all, the
> > gen_id's are all after C's stamp, and the same_context_xhlock() test
> > will also pass because they're all from IRQ context (albeit not the
> > same, but it cannot tell).
> 
> It will stop at xhist[0] because it has been invalidated.
> 
> > Does this explain? Or am I still missing something?
> 
> Could you read the following reply? Not enough?
> 
> https://lkml.org/lkml/2017/7/13/214
> 
> I am sorry if my english makes you hard to understand. But I already
> answered all you asked.

Ah, I think I see. It works because you commit backwards and terminate
on the invalidate.

Yes I had seen your emails, but the penny hadn't dropped, the light bulb
didn't switch on, etc.. sometimes I'm a little dense and need a little
more help.

Thanks, I'll go look at your latest posting now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
