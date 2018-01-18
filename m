Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3CFC6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 23:01:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w186so13318573pgb.10
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 20:01:49 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id be8si5821854plb.428.2018.01.17.20.01.47
        for <linux-mm@kvack.org>;
        Wed, 17 Jan 2018 20:01:48 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
 <20180117120446.44ewafav7epaibde@pathway.suse.cz>
 <4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
 <20180117211953.2403d189@vmware.local.home>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <171cf5b9-2cb6-8e70-87f5-44ace35c2ce4@lge.com>
Date: Thu, 18 Jan 2018 13:01:46 +0900
MIME-Version: 1.0
In-Reply-To: <20180117211953.2403d189@vmware.local.home>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/18/2018 11:19 AM, Steven Rostedt wrote:
> On Thu, 18 Jan 2018 10:53:37 +0900
> Byungchul Park <byungchul.park@lge.com> wrote:
> 
>> Hello,
>>
>> This is a thing simulating a wait for an event e.g.
>> wait_for_completion() doing spinning instead of sleep, rather
>> than a spinlock. I mean:
>>
>>      This context
>>      ------------
>>      while (READ_ONCE(console_waiter)) /* Wait for the event */
>>         cpu_relax();
>>
>>      Another context
>>      ---------------
>>      WRITE_ONCE(console_waiter, false); /* Event */
> 
> I disagree. It is like a spinlock. You can say a spinlock() that is
> blocked is also waiting for an event. That event being the owner does a
> spin_unlock().

That's exactly what I was saying. Excuse me but, I don't understand
what you want to say. Could you explain more? What do you disagree?

>>
>> That's why I said this's the exact case of cross-release. Anyway
>> without cross-release, we usually use typical acquire/release
>> pairs to cover a wait for an event in the following way:
>>
>>      A context
>>      ---------
>>      lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
>>                              /* Read one is better though..    */
>>
>>      /* A section, we suspect, a wait for an event might happen. */
>>      ...
>>      lock_map_release(wait);
>>
>>
>>      The place actually doing the wait
>>      ---------------------------------
>>      lock_map_acquire(wait);
>>      lock_map_acquire(wait);
>>
>>      wait_for_event(wait); /* Actually do the wait */
>>
>> You can see a simple example of how to use them by searching
>> kernel/cpu.c with "lock_acquire" and "wait_for_completion".
>>
>> However, as I said, if you suspect that cpu_relax() includes
>> the wait, then it's ok to leave it. Otherwise, I think it
>> would be better to change it in the way I showed you above.
> 
> I find your way confusing. I'm simulating a spinlock not a wait for
> completion. A wait for completion usually initiates something then

I used the word, *event* instead of *completion*. wait_for_completion()
and complete() are just an example of a pair of waiter and event.
Lock and unlock can also be another example, too.

Important thing is that who waits and who triggers the event. Using the
pair, we can achieve various things, for examples:

    1. Synchronization like wait_for_completion() does.
    2. Control exclusively entering into a critical area.
    3. Whatever.

> waits for it to complete. This is trying to get into a critical area
> but another task is currently in it. It's simulating a spinlock as far
> as I can see.

Anyway it's an example of "waiter for an event, and the event".

JFYI, spinning or sleeping does not matter. Those are just methods to
achieve a wait. I know you're not talking about this though. It's JFYI.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
