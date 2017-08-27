Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BAFD86B025F
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 19:12:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id d66so8266655oib.2
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 16:12:21 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id r205si9177731oig.374.2017.08.27.16.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Aug 2017 16:12:20 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id c18so2394479ioj.2
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 16:12:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx0NjiHM5Aw0N7xDwRcnHOiaceV2iYuGOU1uM3FUyf+Lg@mail.gmail.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com> <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
 <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com> <CA+55aFx0NjiHM5Aw0N7xDwRcnHOiaceV2iYuGOU1uM3FUyf+Lg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Aug 2017 16:12:19 -0700
Message-ID: <CA+55aFwuyqm6xMmS0PdjDZbgrXTiXkH+cGua=npXLaEnzOUGjw@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Nick Piggin <npiggin@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, Aug 27, 2017 at 2:40 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The race goes like this:
>
>   thread1       thread2         thread3
>   ----          ----            ----
>
>   .. CPU1 ...
>   __lock_page_killable
>     wait_on_page_bit_common()
>       get wq lock
>       __add_wait_queue_entry_tail_exclusive()
>       set_current_state(TASK_KILLABLE);
>       release wq lock
>         io_schedule
>
>                 ... CPU2 ...
>                 __lock_page[_killable]()
>                   wait_on_page_bit_common()
>                     get wq lock
>                     __add_wait_queue_entry_tail_exclusive()
>                     set_current_state(TASK_KILLABLE);
>                     release wq lock
>                     io_schedule
>
>                                 ... CPU3 ...
>                                 unlock_page()
>                                 wake_up_page_bit(page, PG_Locked)
>                                   wakes up CPU1 _only_
>
>   ... lethal signal for thread1 happens ...
>      if (unlikely(signal_pending_state(state, current))) {
>           ret = -EINTR;
>           break;
>      }

With the race meaning that thread2 never gets woken up due to the
exclusive wakeup being caught by thread1 (which doesn't actually take
the lock).

I think that this bug was introduced by commit 62906027091f ("mm: add
PageWaiters indicating tasks are waiting for a page bit"), which
changed the page lock from using the wait_on_bit_lock() code to its
own _slightly_ different version.

Because it looks like _almost_ the same thing existed in the old
wait_on_bit_lock() code - and that is still used by a couple of
filesystems.

*Most* of the users seem to use TASK_UNINTERRUPTIBLE, which is fine.
But cifs and the sunrpc XPRT_LOCKED code both use the TASK_KILLABLE
form that would seem to have the exact same issue: wait_on_bit_lock()
uses exclusive wait-queues, but then may return with an error without
actually taking the lock.

Now, it turns out that I think the wait_on_bit_lock() code is actually
safe, for a subtle reason.

Why? Unlike the page lock code, the wait_on_bit_lock() code always
tries to get the lock bit before returning an error. So
wait_on_bit_lock() will prefer a successful lock taking over EINTR,
which means that if the bit really was unlocked, it would have been
taken.

And if something else locked the bit again under us and we didn't get
it, that "something else" presumably will then wake things up when it
unlocks.

So the wait_on_bit_lock() code could _also_ lose the wakeup event, but
it would only lose it in situations where somebody else would then
re-send it.

Do people agree with that analysis?

So I think the old wait_on_bit_lock() code ends up being safe -
despite having this same pattern of "exclusive wait but might error
out without taking the lock".

Whether that "wait_on_bit_lock() is safe" was just a fluke or was
because people thought about it is unclear. It's old code. People
probably *did* think about it. I really can't remember.

But it does point to a fix for the page lock case: just move the
signal_pending_state() test to after the bit checking.

So the page locking code is racy because you could have this:

 - another cpu does the unlock_page() and wakes up the process (and
uses the exclusive event)

 - we then get a lethal signal before we get toi the
"signal_pending_state()" state.

 - we end up prioritizing the lethal signal, because obviously we
don't care about locking the page any more.

 - so now the lock bit may be still clear and there's nobody who is
going to wake up the remaining waiter

Moving the signal_pending_state() down actually fixes the race,
because we know that in order for the exclusive thing to have
mattered, it *has* to actually wake us up. So the unlock_page() must
happen before the lethal signal (where before is well-defined because
of that "try_to_wake_up()" taking a lock and looking at the task
state). The exclusive accounting is only done if the process is
actually woken up, not if it was already running (see
"try_to_wake_up()").

And if the unlock_page() happened before the lethal signal, then we
know that test_and_set_bit_lock() will either work (in which case
we're ok), or another locker successfully came in later - in which
case we're _also_ ok, because that other locker will then do the
unlock again, and wake up subsequent waiters that might have been
blocked by our first exclusive waiter.

So I propose that the fix might be as simple as this:

    diff --git a/mm/filemap.c b/mm/filemap.c
    index baba290c276b..0b41c8cbeabc 100644
    --- a/mm/filemap.c
    +++ b/mm/filemap.c
    @@ -986,10 +986,6 @@ static inline int
wait_on_page_bit_common(wait_queue_head_t *q,

                if (likely(test_bit(bit_nr, &page->flags))) {
                        io_schedule();
    -                   if (unlikely(signal_pending_state(state, current))) {
    -                           ret = -EINTR;
    -                           break;
    -                   }
                }

                if (lock) {
    @@ -999,6 +995,11 @@ static inline int
wait_on_page_bit_common(wait_queue_head_t *q,
                        if (!test_bit(bit_nr, &page->flags))
                                break;
                }
    +
    +           if (unlikely(signal_pending_state(state, current))) {
    +                   ret = -EINTR;
    +                   break;
    +           }
        }

        finish_wait(q, wait);

but maybe I'm missing something.

Nick, comments?

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
