Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A362128027D
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 23:54:20 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id m1so7558726pls.20
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 20:54:20 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 33si3509532pll.277.2018.01.16.20.54.17
        for <linux-mm@kvack.org>;
        Tue, 16 Jan 2018 20:54:18 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
From: Byungchul Park <byungchul.park@lge.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
Message-ID: <83e4baf9-6ece-6e81-1864-689934b7733a@lge.com>
Date: Wed, 17 Jan 2018 13:54:15 +0900
MIME-Version: 1.0
In-Reply-To: <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/17/2018 11:19 AM, Byungchul Park wrote:
> On 1/10/2018 10:24 PM, Petr Mladek wrote:
>> From: Steven Rostedt <rostedt@goodmis.org>
>>
>> From: Steven Rostedt (VMware) <rostedt@goodmis.org>
>>
>> This patch implements what I discussed in Kernel Summit. I added
>> lockdep annotation (hopefully correctly), and it hasn't had any splats
>> (since I fixed some bugs in the first iterations). It did catch
>> problems when I had the owner covering too much. But now that the owner
>> is only set when actively calling the consoles, lockdep has stayed
>> quiet.
>>
>> Here's the design again:
>>
>> I added a "console_owner" which is set to a task that is actively
>> writing to the consoles. It is *not* the same as the owner of the
>> console_lock. It is only set when doing the calls to the console
>> functions. It is protected by a console_owner_lock which is a raw spin
>> lock.
>>
>> There is a console_waiter. This is set when there is an active console
>> owner that is not current, and waiter is not set. This too is protected
>> by console_owner_lock.
>>
>> In printk() when it tries to write to the consoles, we have:
>>
>> A A A A if (console_trylock())
>> A A A A A A A  console_unlock();
>>
>> Now I added an else, which will check if there is an active owner, and
>> no current waiter. If that is the case, then console_waiter is set, and
>> the task goes into a spin until it is no longer set.
>>
>> When the active console owner finishes writing the current message to
>> the consoles, it grabs the console_owner_lock and sees if there is a
>> waiter, and clears console_owner.
>>
>> If there is a waiter, then it breaks out of the loop, clears the waiter
>> flag (because that will release the waiter from its spin), and exits.
>> Note, it does *not* release the console semaphore. Because it is a
>> semaphore, there is no owner. Another task may release it. This means
>> that the waiter is guaranteed to be the new console owner! Which it
>> becomes.
>>
>> Then the waiter calls console_unlock() and continues to write to the
>> consoles.
>>
>> If another task comes along and does a printk() it too can become the
>> new waiter, and we wash rinse and repeat!
>>
>> By Petr Mladek about possible new deadlocks:
>>
>> The thing is that we move console_sem only to printk() call
>> that normally calls console_unlock() as well. It means that
>> the transferred owner should not bring new type of dependencies.
>> As Steven said somewhere: "If there is a deadlock, it was
>> there even before."
>>
>> We could look at it from this side. The possible deadlock would
>> look like:
>>
>> CPU0A A A A A A A A A A A A A A A A A A A A A A A A A A A  CPU1
>>
>> console_unlock()
>>
>> A A  console_owner = current;
>>
>> A A A A A A A A A A A A A A A  spin_lockA()
>> A A A A A A A A A A A A A A A A A  printk()
>> A A A A A A A A A A A A A A A A A A A  spin = true;
>> A A A A A A A A A A A A A A A A A A A  while (...)
>>
>> A A A A  call_console_drivers()
>> A A A A A A  spin_lockA()
>>
>> This would be a deadlock. CPU0 would wait for the lock A.
>> While CPU1 would own the lockA and would wait for CPU0
>> to finish calling the console drivers and pass the console_sem
>> owner.
>>
>> But if the above is true than the following scenario was
>> already possible before:
>>
>> CPU0
>>
>> spin_lockA()
>> A A  printk()
>> A A A A  console_unlock()
>> A A A A A A  call_console_drivers()
>> A A A A spin_lockA()
>>
>> By other words, this deadlock was there even before. Such
>> deadlocks are prevented by using printk_deferred() in
>> the sections guarded by the lock A.
> 
> Hello,
> 
> I didn't see what you did, at the last version. You were
> tring to transfer the semaphore owner and make it taken
> over. I see.
> 
> But, what I mentioned last time is still valid. See below.

Of course, it's not an important thing but trivial one though.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
