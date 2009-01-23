Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9EFD06B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 19:26:30 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so2357590fge.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2009 16:26:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090122202550.GA5726@redhat.com>
References: <20090117215110.GA3300@redhat.com>
	 <20090118013802.GA12214@cmpxchg.org>
	 <20090118023211.GA14539@redhat.com>
	 <20090120203131.GA20985@cmpxchg.org>
	 <20090121143602.GA16584@redhat.com>
	 <20090121213813.GB23270@cmpxchg.org>
	 <20090122202550.GA5726@redhat.com>
Date: Fri, 23 Jan 2009 01:26:28 +0100
Message-ID: <b647ffbd0901221626o5e654682t147625fa3e19976f@mail.gmail.com>
Subject: Re: [RFC v4] wait: prevent waiter starvation in __wait_on_bit_lock
From: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2009/1/22 Oleg Nesterov <oleg@redhat.com>:
> On 01/21, Johannes Weiner wrote:
>>
>> @@ -187,6 +187,31 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
>>               }
>>       } while (test_and_set_bit(q->key.bit_nr, q->key.flags));
>>       finish_wait(wq, &q->wait);
>> +     if (unlikely(ret)) {
>> +             /*
>> +              * Contenders are woken exclusively.  If we were woken
>> +              * by an unlock we have to take the lock ourselves and
>> +              * wake the next contender on unlock.  But the waiting
>> +              * function failed, we do not take the lock and won't
>> +              * unlock in the future.  Make sure the next contender
>> +              * does not wait forever on an unlocked bit.
>> +              *
>> +              * We can also get here without being woken through
>> +              * the waitqueue, so there is a small chance of doing a
>> +              * bogus wake up between an unlock clearing the bit and
>> +              * the next contender being woken up and setting it again.
>> +              *
>> +              * It does no harm, though, the scheduler will ignore it
>> +              * as the process in question is already running.
>> +              *
>> +              * The unlock path clears the bit and then wakes up the
>> +              * next contender.  If the next contender is us, the
>> +              * barrier makes sure we also see the bit cleared.
>> +              */
>> +             smp_rmb();
>> +             if (!test_bit(q->key.bit_nr, q->key.flags)))
>> +                     __wake_up_bit(wq, q->key.flags, q->key.bit_nr);
>
> I think this is correct, and (unfortunately ;) you are right:
> we need rmb() even after finish_wait().

Hum, I think it's actually not necessary in this particular case when
(1) "the next contender is us" and (2) we are in the "ret != 0" path
so that the only thing we really care about -- if we were exclusivly
woken up, then wake up somebody else [*].

"the next contender is us" implies that we were still on the 'wq'
queue when __wake_up_bit() -> __wake_up() has been called, meaning
that wq->lock has also been taken (in __wake_up()).

Now, on our side, we are definitely on the 'wq' queue before calling
finish_wait(), meaning that we also take the wq->lock.

In short, wq->lock is a sync. mechanism in this case. The scheme is as follows:

our side:

[ finish_wait() ]

lock(wq->lock);
delete us from the 'wq'
unlock(wq->lock);

test_bit()   [ read a bit ]


waker's side:

clear_bit()
smp_mb__after_clear_bit() --- is a must to ensure that we fetch the
'wq' (and do a waitqueue_active(wq) check) in __wake_up_bit() _only_
after clearing the bit.

[ __wake_up_bit(); -> __wake_up() ] --> we are on the 'wq' (see conditions [*])
lock(wq->lock);
wake 'us' up here
unlock(wq->lock);


Now the point is, without smp_rmb() on the side of wait_on_bit(),
test_bit() [ which is a LOAD op ]can get _into_ the wq->lock section,
smth like this:

[ finish_wait() ]

lock(wq->lock);
test_bit()   [ read a bit ]
delete us from the 'wq'
unlock(wq->lock);

If (1) is true (we were woken up indeed), it means that __wake_up()
(from __wake_up_bit()) has been executed before we were able to enter
finish_wait().

By the moment __wake_up_bit() was executed (we were woken up), the bit
was already cleared -- that's guaranteed by a full MB on the
wake_up_bit side (in our case [*] wq->lock would do it even without
the MB) -> meaning that we don't miss !test_bit() int this particular
case [*].

p.s. if the explanation is vague or heh even wrong, it's definitely
due to the lack of sleep ;-))

>
> For example, don't we have the similar problems with
> wait_event_interruptible_exclusive() ?

yes, I think so.


>
> Oleg.
>

-- 
Best regards,
Dmitry Adamushko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
