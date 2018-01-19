Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 352B96B027E
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 21:37:22 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g186so384118pfb.11
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 18:37:22 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r1si7123459pgp.320.2018.01.18.18.37.19
        for <linux-mm@kvack.org>;
        Thu, 18 Jan 2018 18:37:20 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
 <20180117120446.44ewafav7epaibde@pathway.suse.cz>
 <4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
 <20180117211953.2403d189@vmware.local.home>
 <171cf5b9-2cb6-8e70-87f5-44ace35c2ce4@lge.com>
 <20180118102139.43c04de5@gandalf.local.home>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <45bc7a00-2f7f-3319-bfed-e7b9cd7a8571@lge.com>
Date: Fri, 19 Jan 2018 11:37:13 +0900
MIME-Version: 1.0
In-Reply-To: <20180118102139.43c04de5@gandalf.local.home>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/19/2018 12:21 AM, Steven Rostedt wrote:
> On Thu, 18 Jan 2018 13:01:46 +0900
> Byungchul Park <byungchul.park@lge.com> wrote:
> 
>>> I disagree. It is like a spinlock. You can say a spinlock() that is
>>> blocked is also waiting for an event. That event being the owner does a
>>> spin_unlock().
>>
>> That's exactly what I was saying. Excuse me but, I don't understand
>> what you want to say. Could you explain more? What do you disagree?
> 
> I guess I'm confused at what you are asking for then.

Sorry for not enough explanation. What I asked you for is:

    1. Relocate acquire()s/release()s.
    2. So make it simpler and remove unnecessary one.
    3. So make it look like the following form,
       because it's a thing simulating "wait and event".

       A context
       ---------
       lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
                               /* "Read" one is better though..    */

       /* A section, we suspect a wait for an event might happen. */
       ...

       lock_map_release(wait);

       The place actually doing the wait
       ---------------------------------
       lock_map_acquire(wait);
       lock_map_release(wait);

       wait_for_event(wait); /* Actually do the wait */

Honestly, you used acquire()s/release()s as if they are cross-
release stuff which mainly handles general waits and events,
not only things doing "acquire -> critical area -> release".
But that's not in the mainline at the moment.

>>> I find your way confusing. I'm simulating a spinlock not a wait for
>>> completion. A wait for completion usually initiates something then
>>
>> I used the word, *event* instead of *completion*. wait_for_completion()
>> and complete() are just an example of a pair of waiter and event.
>> Lock and unlock can also be another example, too.
>>
>> Important thing is that who waits and who triggers the event. Using the
>> pair, we can achieve various things, for examples:
>>
>>      1. Synchronization like wait_for_completion() does.
>>      2. Control exclusively entering into a critical area.
>>      3. Whatever.
>>
>>> waits for it to complete. This is trying to get into a critical area
>>> but another task is currently in it. It's simulating a spinlock as far
>>> as I can see.
>>
>> Anyway it's an example of "waiter for an event, and the event".
>>
>> JFYI, spinning or sleeping does not matter. Those are just methods to
          ^
          whether spining or sleeping doesn't matter.

>> achieve a wait. I know you're not talking about this though. It's JFYI.
> 
> OK, if it is just FYI.

Actually, the last paragraph is JFYI tho.

> -- Steve
> 
> 
> 

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
