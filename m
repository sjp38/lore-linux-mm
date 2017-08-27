Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 890EC6B0506
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 17:40:50 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l185so5569897oib.4
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 14:40:50 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id h205si9487987oif.319.2017.08.27.14.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Aug 2017 14:40:49 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id w204so3144187ita.1
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 14:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com> <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com>
 <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com> <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Aug 2017 14:40:48 -0700
Message-ID: <CA+55aFx0NjiHM5Aw0N7xDwRcnHOiaceV2iYuGOU1uM3FUyf+Lg@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Aug 26, 2017 at 11:15 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So how about just this fairly trivial patch?

So I just committed that trivial patch, because I think it's right,
but more importantly because I think I found a real and non-trivial
fundamental problem.

The reason I found it is actually that I was thinking about this
patch, and how the WQ_FLAG_EXCLUSIVE ordering matters.

And I don't really think the WQ_FLAG_EXCLUSIVE ordering matters all
that much, but just *thinking* about it made me realize that the code
is broken.

In particular, this caller:

    int __lock_page_killable(struct page *__page)
    {
        struct page *page = compound_head(__page);
        wait_queue_head_t *q = page_waitqueue(page);
        return wait_on_page_bit_common(q, page, PG_locked, TASK_KILLABLE, true);
    }
    EXPORT_SYMBOL_GPL(__lock_page_killable);

is completely broken crap.

Why?

It's the combination of "TASK_KILLABLE" and "true" that is broken.
Always has been broken, afaik.

The "true" is that "bool lock" argument, and when it is set, we set
the WQ_FLAG_EXCLUSIVE bit.

But that bit - by definition, that's the whole point - means that the
waking side only wakes up *one* waiter.

So there's a race in anybody who uses __lock_page_killable().

The race goes like this:

  thread1       thread2         thread3
  ----          ----            ----

  .. CPU1 ...
  __lock_page_killable
    wait_on_page_bit_common()
      get wq lock
      __add_wait_queue_entry_tail_exclusive()
      set_current_state(TASK_KILLABLE);
      release wq lock
        io_schedule

                ... CPU2 ...
                __lock_page[_killable]()
                  wait_on_page_bit_common()
                    get wq lock
                    __add_wait_queue_entry_tail_exclusive()
                    set_current_state(TASK_KILLABLE);
                    release wq lock
                    io_schedule

                                ... CPU3 ...
                                unlock_page()
                                wake_up_page_bit(page, PG_Locked)
                                  wakes up CPU1 _only_

  ... lethal signal for thread1 happens ...
     if (unlikely(signal_pending_state(state, current))) {
          ret = -EINTR;
          break;
     }


End result: page is unlocked, CPU3 is waiting, nothing will wake CPU3 up.

Of course, if we have multiple threads all locking that page
concurrently, we probably will have *another* thread lock it
(successfully), and then when it unlocks it thread3 does get woken up
eventually.

But the keyword is "eventually". It could be a long while,
particularly if we don't lock the page *all* the time, just
occasionally.

So it might be a while, and it might explain how some waiters might queue up.

And who does __lock_page_killable? Page faults.

And who does a lot of page faults and page locking? That NUMA load from hell.

Does it have lethal signals, though? Probably not. That lethal signal
case really is unusual.

So I'm not saying that this is actually THE BUG. In particular,
despite that race, the page actually *is* unlocked afterwards. It's
just that one of the threads that wanted the lock didn't get notified
of it. So it doesn't really explain how non-locking waiters (ie the
people who don't do migrations, just wait for the migration entry)
would queue up.

But it sure looks like a real bug to me.

Basically, if you ask for anm exclusive wakeup, you *have* to take the
resource you are waiting for. Youl can't just say "never mind, I'll
return -EINTR".

I don't see a simple fix for this yet other than perhaps adding a
wakeup to the "ret = -EINTR; break" case.

Does anybody else see anything? Or maybe see a reason why this
wouldn't be a bug in the first place?

Anyway, I am officially starting to hate that page wait code.  I've
stared at it for days now, and I am not getting more fond of it.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
