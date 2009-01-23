Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 48B316B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 07:36:36 -0500 (EST)
Received: by mu-out-0910.google.com with SMTP id i2so3143712mue.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2009 04:36:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090123110500.GA12684@redhat.com>
References: <20090117215110.GA3300@redhat.com>
	 <20090118023211.GA14539@redhat.com>
	 <20090120203131.GA20985@cmpxchg.org>
	 <20090121143602.GA16584@redhat.com>
	 <20090121213813.GB23270@cmpxchg.org>
	 <20090122202550.GA5726@redhat.com>
	 <b647ffbd0901221626o5e654682t147625fa3e19976f@mail.gmail.com>
	 <20090123004702.GA18362@redhat.com>
	 <b647ffbd0901230207u642e24cdg98700aa68ed1aa33@mail.gmail.com>
	 <20090123110500.GA12684@redhat.com>
Date: Fri, 23 Jan 2009 13:36:33 +0100
Message-ID: <b647ffbd0901230436x3408203bw10834d013beab16c@mail.gmail.com>
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
>> 2009/1/23 Oleg Nesterov <oleg@redhat.com>:
>> > On 01/23, Dmitry Adamushko wrote:
>> >>
>> >> In short, wq->lock is a sync. mechanism in this case. The scheme is as follows:
>> >>
>> >> our side:
>> >>
>> >> [ finish_wait() ]
>> >>
>> >> lock(wq->lock);
>> >
>> > But we can skip lock(wq->lock), afaics.
>> >
>> > Without rmb(), test_bit() can be re-ordered with list_empty_careful()
>> > in finish_wait() and even with __set_task_state(TASK_RUNNING).
>>
>> But taking into account the constraints of this special case, namely
>> (1), we can't skip lock(wq->lock).
>>
>> (1) "the next contender is us"
>>
>> In this particular situation, we are only interested in the case when
>> we were woken up by __wake_up_bit().
>
> Yes,
>
>> that means we are _on_ the 'wq' list when we do finish_wait() -> we do
>> take the 'wq->lock'.
>
> Hmm. No?
>
> We are doing exclusive wait, and we use autoremove_wake_function().
> If we were woken, we are removed from ->task_list.

Argh, right, somehow I've made wrong assumptions on the wake-up part :-/


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
