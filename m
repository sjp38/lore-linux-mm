Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE736B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 03:18:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a186so21904791pge.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 00:18:57 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id 22si1516570pgc.392.2017.08.28.00.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 00:18:56 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id q16so5771255pgc.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 00:18:56 -0700 (PDT)
Date: Mon, 28 Aug 2017 17:18:27 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in
 wake_up_page_bit
Message-ID: <20170828171827.1dc41715@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFy0WnCeR-WaBQFtsvES1zJpR8BHRRL3aTrwQrUQbFq0fQ@mail.gmail.com>
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
	<20170828112959.05622961@roar.ozlabs.ibm.com>
	<CA+55aFy0WnCeR-WaBQFtsvES1zJpR8BHRRL3aTrwQrUQbFq0fQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, 27 Aug 2017 22:17:55 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Aug 27, 2017 at 6:29 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > BTW. since you are looking at this stuff, one other small problem I remember
> > with exclusive waiters is that losing to a concurrent locker puts them to
> > the back of the queue. I think that could be fixed with some small change to
> > the wait loops (first add to tail, then retries add to head). Thoughts?  
> 
> No, not that way.
> 
> First off, it's oddly complicated, but more importantly, the real
> unfairness you lose to is not other things on the wait queue, but to
> other lockers that aren't on the wait-queue at all, but instead just
> come in and do a "test-and-set" without ever even going through the
> slow path.

Right, there is that unfairness *as well*. The requeue-to-tail logic
seems to make that worse and I thought it seemed like a simple way
to improve it.

> 
> So instead of playing queuing games, you'd need to just change the
> unlock sequence. Right now we basically do:
> 
>  - clear lock bit and atomically test if contended (and we play games
> with bit numbering to do that atomic test efficiently)
> 
>  - if contended, wake things up
> 
> and you'd change the logic to be
> 
>  - if contended, don't clear the lock bit at all, just transfer the
> lock ownership directly to the waiters by walking the wait list
> 
>  - clear the lock bit only once there are no more wait entries (either
> because there were no waiters at all, or because all the entries were
> just waiting for the lock to be released)
> 
> which is certainly doable with a couple of small extensions to the
> page wait key data structure.

Yeah that would be ideal. Conceptually trivial, I guess care has to
be taken with transferring the memory ordering with the lock. Could
be a good concept to apply elsewhere too.

> 
> But most of my clever schemes the last few days were abject failures,
> and honestly, it's late in the rc.
> 
> In fact, this late in the game I probably wouldn't even have committed
> the small cleanups I did if it wasn't for the fact that thinking of
> the whole WQ_FLAG_EXCLUSIVE bit made me find the bug.
> 
> So the cleanups were actually what got me to look at the problem in
> the first place, and then I went "I'm going to commit the cleanup, and
> then I can think about the bug I just found".
> 
> I'm just happy that the fix seems to be trivial. I was afraid I'd have
> to do something nastier (like have the EINTR case send another
> explicit wakeup to make up for the lost one, or some ugly hack like
> that).
> 
> It was only when I started looking at the history of that code, and I
> saw the old bit_lock code, and I went "Hmm. That has the _same_ bug -
> oh wait, no it doesn't!" that I realized that there was that simple
> fix.
> 
> You weren't cc'd on the earlier part of the discussion, you only got
> added when I realized what the history and simple fix was.

You're right, no such improvement would be appropriate for 4.14.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
