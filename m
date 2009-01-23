Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EA56B6B0083
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 05:07:50 -0500 (EST)
Received: by mu-out-0910.google.com with SMTP id i2so3087328mue.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2009 02:07:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090123004702.GA18362@redhat.com>
References: <20090117215110.GA3300@redhat.com>
	 <20090118013802.GA12214@cmpxchg.org>
	 <20090118023211.GA14539@redhat.com>
	 <20090120203131.GA20985@cmpxchg.org>
	 <20090121143602.GA16584@redhat.com>
	 <20090121213813.GB23270@cmpxchg.org>
	 <20090122202550.GA5726@redhat.com>
	 <b647ffbd0901221626o5e654682t147625fa3e19976f@mail.gmail.com>
	 <20090123004702.GA18362@redhat.com>
Date: Fri, 23 Jan 2009 11:07:48 +0100
Message-ID: <b647ffbd0901230207u642e24cdg98700aa68ed1aa33@mail.gmail.com>
Subject: Re: [RFC v4] wait: prevent waiter starvation in __wait_on_bit_lock
From: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matthew Wilcox <matthew@wil.cx>, Chuck Lever <cel@citi.umich.edu>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2009/1/23 Oleg Nesterov <oleg@redhat.com>:
> On 01/23, Dmitry Adamushko wrote:
>>
>> 2009/1/22 Oleg Nesterov <oleg@redhat.com>:
>> >
>> > I think this is correct, and (unfortunately ;) you are right:
>> > we need rmb() even after finish_wait().
>>
>> Hum, I think it's actually not necessary in this particular case when
>> (1) "the next contender is us" and (2) we are in the "ret != 0" path
>> so that the only thing we really care about -- if we were exclusivly
>> woken up, then wake up somebody else [*].
>>
>> "the next contender is us" implies that we were still on the 'wq'
>> queue when __wake_up_bit() -> __wake_up() has been called, meaning
>> that wq->lock has also been taken (in __wake_up()).
>>
>> Now, on our side, we are definitely on the 'wq' queue before calling
>> finish_wait(), meaning that we also take the wq->lock.
>>
>> In short, wq->lock is a sync. mechanism in this case. The scheme is as follows:
>>
>> our side:
>>
>> [ finish_wait() ]
>>
>> lock(wq->lock);
>
> But we can skip lock(wq->lock), afaics.
>
> Without rmb(), test_bit() can be re-ordered with list_empty_careful()
> in finish_wait() and even with __set_task_state(TASK_RUNNING).

But taking into account the constraints of this special case, namely
(1), we can't skip lock(wq->lock).

(1) "the next contender is us"

In this particular situation, we are only interested in the case when
we were woken up by __wake_up_bit().

that means we are _on_ the 'wq' list when we do finish_wait() -> we do
take the 'wq->lock'.

Moreover, imagine the following case (roughly similar to finish_wait()):

if (LOAD(a) == 1) {
    // do something here
    mb();
}

LOAD(b);

Can LOAD(b) be reordered with LOAD(a)?

I'd imagine that it can be done with CPUs that do execute 2 branch
paths in advance but then LOAD(b) must be re-loaded if (a == 1) and we
hit mb().


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
