Received: by ug-out-1314.google.com with SMTP id s2so788381uge
        for <linux-mm@kvack.org>; Sat, 12 May 2007 06:44:31 -0700 (PDT)
Date: Sat, 12 May 2007 15:44:19 +0200 (CEST)
From: Esben Nielsen <nielsen.esben@googlemail.com>
Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
In-Reply-To: <1178964103.6810.55.camel@twins>
Message-ID: <Pine.LNX.4.64.0705121520210.2101@frodo.shire>
References: <20070511131541.992688403@chello.nl>  <Pine.LNX.4.64.0705121120210.26287@frodo.shire>
 <1178964103.6810.55.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Esben Nielsen <nielsen.esben@googlemail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


On Sat, 12 May 2007, Peter Zijlstra wrote:

> On Sat, 2007-05-12 at 11:27 +0200, Esben Nielsen wrote:
>>
>> On Fri, 11 May 2007, Peter Zijlstra wrote:
>>
>>>
>>> I was toying with a scalable rw_mutex and found that it gives ~10% reduction in
>>> system time on ebizzy runs (without the MADV_FREE patch).
>>>
>>
>> You break priority enheritance on user space futexes! :-(
>> The problems is that the futex waiter have to take the mmap_sem. And as
>> your rw_mutex isn't PI enabled you get priority inversions :-(
>
> Do note that rwsems have no PI either.
> PI is not a concern for mainline - yet, I do have ideas here though.
>
>
If PI wasn't a concern for mainline, why is PI futexes merged into the 
mainline?

I notice that the rwsems used now isn't priority inversion safe (thus 
destroyingthe perpose of having PI futexes). We thus already have a bug in 
the mainline.

I suggest making a rw_mutex which does read side PI: A reader boosts the 
writer, but a writer can't boost the readers, since there can be a large 
amount of those.

I don't have time to make such a rw_mutex but I have a simple idea for 
one, where the rt_mutex can be reused.

  struct pi_rw_mutex {
       int count; /*  0   -> unoccupied,
                      >0 -> the number of current readers,
                            Second highest bit: there are a waiting writer
                      -1 -> A writer have it. */
       struct rt_mutex mutex;
  }

Use atomic exchange on count.

When locking:

A writer checks if count <= 0. If so it sets the value to -1 and takes
the mutex. When it gets the mutex it rechecks the count and proceeds.
If count > 0 the writer sets the second highest bit and add itself to
the wait-list in the mutex and sleeps. (The mutex will now be in a state 
where owner==NULL but there are waiters. It must be cheched if the 
rt_mutex code can handle this.)

A reader checks if count >= 0. If so it does count++ and proceeds.
If count < 0 it takes the rtmutex. When it gets the mutex it sets the 
count to 1, unlocks the mutex and proceeds.

When unlocking:

The writer sets count to 0 or 0x8000000 (second highest bit) depending 
on how many waiters the mutex have and unlocks the mutex.

The reader checks if count is 0x80000001. If so it sets count to 0 and 
wakes up the first waiter on the mutex (if there are any). Otherwise it 
just do count--.

Esben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
