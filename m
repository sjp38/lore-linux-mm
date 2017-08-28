Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3446B0387
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 21:30:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p69so11854230pfk.10
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 18:30:15 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id k71si8539123pfc.508.2017.08.27.18.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Aug 2017 18:30:14 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id t193so2187190pgc.4
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 18:30:14 -0700 (PDT)
Date: Mon, 28 Aug 2017 11:29:59 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
Message-ID: <20170828112959.05622961@roar.ozlabs.ibm.com>
In-Reply-To: <20170828111648.22f81bc5@roar.ozlabs.ibm.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
	<cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
	<CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
	<f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com>
	<CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
	<CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
	<CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
	<CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
	<CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
	<CA+55aFx0NjiHM5Aw0N7xDwRcnHOiaceV2iYuGOU1uM3FUyf+Lg@mail.gmail.com>
	<CA+55aFwuyqm6xMmS0PdjDZbgrXTiXkH+cGua=npXLaEnzOUGjw@mail.gmail.com>
	<20170828111648.22f81bc5@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 28 Aug 2017 11:16:48 +1000
Nicholas Piggin <npiggin@gmail.com> wrote:

> On Sun, 27 Aug 2017 16:12:19 -0700
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 

> >     diff --git a/mm/filemap.c b/mm/filemap.c
> >     index baba290c276b..0b41c8cbeabc 100644
> >     --- a/mm/filemap.c
> >     +++ b/mm/filemap.c
> >     @@ -986,10 +986,6 @@ static inline int
> > wait_on_page_bit_common(wait_queue_head_t *q,
> > 
> >                 if (likely(test_bit(bit_nr, &page->flags))) {
> >                         io_schedule();
> >     -                   if (unlikely(signal_pending_state(state, current))) {
> >     -                           ret = -EINTR;
> >     -                           break;
> >     -                   }
> >                 }
> > 
> >                 if (lock) {
> >     @@ -999,6 +995,11 @@ static inline int
> > wait_on_page_bit_common(wait_queue_head_t *q,
> >                         if (!test_bit(bit_nr, &page->flags))
> >                                 break;
> >                 }
> >     +
> >     +           if (unlikely(signal_pending_state(state, current))) {
> >     +                   ret = -EINTR;
> >     +                   break;
> >     +           }
> >         }
> > 
> >         finish_wait(q, wait);
> > 
> > but maybe I'm missing something.
> > 
> > Nick, comments?  
> 
> No I don't think you're missing something. We surely could lose our only
> wakeup in this window. So an exclusive waiter has to always make sure
> they propagate the wakeup (regardless of what they do with the contended
> resources itself).
> 
> Seems like your fix should solve it. By the look of how wait_on_bit_lock
> is structured, the author probably did think about this case a little
> better than I did :\

BTW. since you are looking at this stuff, one other small problem I remember
with exclusive waiters is that losing to a concurrent locker puts them to
the back of the queue. I think that could be fixed with some small change to
the wait loops (first add to tail, then retries add to head). Thoughts?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
