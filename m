Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA6896B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 20:53:41 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f3so4609366pga.9
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:53:41 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h82si5508807pfd.219.2018.01.17.17.53.39
        for <linux-mm@kvack.org>;
        Wed, 17 Jan 2018 17:53:40 -0800 (PST)
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to load
 balance console writes
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
 <20180117120446.44ewafav7epaibde@pathway.suse.cz>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <4a24ce1d-a606-3add-ec30-91ce9a1a1281@lge.com>
Date: Thu, 18 Jan 2018 10:53:37 +0900
MIME-Version: 1.0
In-Reply-To: <20180117120446.44ewafav7epaibde@pathway.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/17/2018 9:04 PM, Petr Mladek wrote:
> On Wed 2018-01-17 11:19:53, Byungchul Park wrote:
>> On 1/10/2018 10:24 PM, Petr Mladek wrote:
>>> From: Steven Rostedt <rostedt@goodmis.org>

[...]

>>> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
>>> index b9006617710f..7e6459abba43 100644
>>> --- a/kernel/printk/printk.c
>>> +++ b/kernel/printk/printk.c
>>> @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility, int level,
>>>    		 * semaphore.  The release will print out buffers and wake up
>>>    		 * /dev/kmsg and syslog() users.
>>>    		 */
>>> -		if (console_trylock())
>>> +		if (console_trylock()) {
>>>    			console_unlock();
>>> +		} else {
>>> +			struct task_struct *owner = NULL;
>>> +			bool waiter;
>>> +			bool spin = false;
>>> +
>>> +			printk_safe_enter_irqsave(flags);
>>> +
>>> +			raw_spin_lock(&console_owner_lock);
>>> +			owner = READ_ONCE(console_owner);
>>> +			waiter = READ_ONCE(console_waiter);
>>> +			if (!waiter && owner && owner != current) {
>>> +				WRITE_ONCE(console_waiter, true);
>>> +				spin = true;
>>> +			}
>>> +			raw_spin_unlock(&console_owner_lock);
>>> +
>>> +			/*
>>> +			 * If there is an active printk() writing to the
>>> +			 * consoles, instead of having it write our data too,
>>> +			 * see if we can offload that load from the active
>>> +			 * printer, and do some printing ourselves.
>>> +			 * Go into a spin only if there isn't already a waiter
>>> +			 * spinning, and there is an active printer, and
>>> +			 * that active printer isn't us (recursive printk?).
>>> +			 */
>>> +			if (spin) {
>>> +				/* We spin waiting for the owner to release us */
>>> +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
>>> +				/* Owner will clear console_waiter on hand off */
>>> +				while (READ_ONCE(console_waiter))
>>> +					cpu_relax();
>>> +
>>> +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
>>
>> Why don't you move this over "while (READ_ONCE(console_waiter))" and
>> right after acquire()?
>>
>> As I said last time, only acquisitions between acquire() and release()
>> are meaningful. Are you taking care of acquisitions within cpu_relax()?
>> If so, leave it.
> 
> We are simulating a spinlock here. The above code corresponds to
> 
> 	    spin_lock(&console_owner_spin_lock);
> 	    spin_unlock(&console_owner_spin_lock);
> 
> I mean that spin_acquire() + while-cycle corresponds
> to spin_lock(). And spin_release() corresponds to
> spin_unlock().

Hello,

This is a thing simulating a wait for an event e.g.
wait_for_completion() doing spinning instead of sleep, rather
than a spinlock. I mean:

    This context
    ------------
    while (READ_ONCE(console_waiter)) /* Wait for the event */
       cpu_relax();

    Another context
    ---------------
    WRITE_ONCE(console_waiter, false); /* Event */

That's why I said this's the exact case of cross-release. Anyway
without cross-release, we usually use typical acquire/release
pairs to cover a wait for an event in the following way:

    A context
    ---------
    lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
                            /* Read one is better though..    */

    /* A section, we suspect, a wait for an event might happen. */
    ...
    lock_map_release(wait);


    The place actually doing the wait
    ---------------------------------
    lock_map_acquire(wait);
    lock_map_acquire(wait);

    wait_for_event(wait); /* Actually do the wait */

You can see a simple example of how to use them by searching
kernel/cpu.c with "lock_acquire" and "wait_for_completion".

However, as I said, if you suspect that cpu_relax() includes
the wait, then it's ok to leave it. Otherwise, I think it
would be better to change it in the way I showed you above.

>>> +				printk_safe_exit_irqrestore(flags);
>>> +
>>> +				/*
>>> +				 * The owner passed the console lock to us.
>>> +				 * Since we did not spin on console lock, annotate
>>> +				 * this as a trylock. Otherwise lockdep will
>>> +				 * complain.
>>> +				 */
>>> +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
>>> +				console_unlock();
>>> +				printk_safe_enter_irqsave(flags);
>>> +			}
>>> +			printk_safe_exit_irqrestore(flags);
>>> +
>>> +		}
>>>    	}
>>>    	return printed_len;
>>> @@ -2141,6 +2196,7 @@ void console_unlock(void)
>>>    	static u64 seen_seq;
>>>    	unsigned long flags;
>>>    	bool wake_klogd = false;
>>> +	bool waiter = false;
>>>    	bool do_cond_resched, retry;
>>>    	if (console_suspended) {
>>> @@ -2229,14 +2285,64 @@ void console_unlock(void)
>>>    		console_seq++;
>>>    		raw_spin_unlock(&logbuf_lock);
>>> +		/*
>>> +		 * While actively printing out messages, if another printk()
>>> +		 * were to occur on another CPU, it may wait for this one to
>>> +		 * finish. This task can not be preempted if there is a
>>> +		 * waiter waiting to take over.
>>> +		 */
>>> +		raw_spin_lock(&console_owner_lock);
>>> +		console_owner = current;
>>> +		raw_spin_unlock(&console_owner_lock);
>>> +
>>> +		/* The waiter may spin on us after setting console_owner */
>>> +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
>>> +
>>>    		stop_critical_timings();	/* don't trace print latency */
>>>    		call_console_drivers(ext_text, ext_len, text, len);
>>>    		start_critical_timings();
>>> +
>>> +		raw_spin_lock(&console_owner_lock);
>>> +		waiter = READ_ONCE(console_waiter);
>>> +		console_owner = NULL;
>>> +		raw_spin_unlock(&console_owner_lock);
>>> +
>>> +		/*
>>> +		 * If there is a waiter waiting for us, then pass the
>>> +		 * rest of the work load over to that waiter.
>>> +		 */
>>> +		if (waiter)
>>> +			break;
>>> +
>>> +		/* There was no waiter, and nothing will spin on us here */
>>> +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
>>
>> Why don't you move this over "if (waiter)"?
> 
> We want to actually release the lock before calling spin_release,
> see below.

Excuse me but, I don't see..

>>> +
>>>    		printk_safe_exit_irqrestore(flags);
>>>    		if (do_cond_resched)
>>>    			cond_resched();
>>>    	}
>>> +
>>> +	/*
>>> +	 * If there is an active waiter waiting on the console_lock.
>>> +	 * Pass off the printing to the waiter, and the waiter
>>> +	 * will continue printing on its CPU, and when all writing
>>> +	 * has finished, the last printer will wake up klogd.
>>> +	 */
>>> +	if (waiter) {
>>> +		WRITE_ONCE(console_waiter, false);
>>> +		/* The waiter is now free to continue */
>>> +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
>>
>> Why don't you remove this release() after relocating the upper one?

You should use this acquire/release pair here to detect if the
following section involves the spinning again for console_waiter:

    stop_critical_timings();
    call_console_drivers(ext_text, ext_len, text, len);
    start_critical_timings();

    raw_spin_lock(&console_owner_lock);
    waiter = READ_ONCE(console_waiter);
    console_owner = NULL;
    raw_spin_unlock(&console_owner_lock);

There should be no more meaning than that.

> The manipulation of "console_waiter" implements the spin_lock that
> we are trying to simulate. It is such easy because it is guaranteed
> that there is always only one process that tries to get this
> fake spin_lock. Also the other waiter releases the spin lock
> immediately after it gets it.
> 
> I mean that WRITE_ONCE(console_waiter, false) causes that
> the simulated spin lock is released here. Also the while-cycle
> in vprintk_emit() succeeds. The while-cycle success means
> that vprintk_emit() actually acquires the simulated spinlock.

I understand what you want to explain. If cross-release was alive,
there might be several things to talk more but now, what I
explained above is all we can do with existing acquire/release.

> This synchronization is need to make sure that the two processes
> pass the console_lock ownership at the right place.
> 
> I think that at least this simulated spin lock is annotated the right
> way by console_owner_dep_map manipulations. And I think that we

I also think it would work logically. I just wanted to say the
code looks like as if it's doing something cross-release stuff,
despite not, and suggest a common way to use typical ones.
That's all. :) I would send a patch if you also think so, but
it's ok even if not.

> do not need the cross-release feature to simulate this spin lock.
> 
> 
>>> +		/*
>>> +		 * Hand off console_lock to waiter. The waiter will perform
>>> +		 * the up(). After this, the waiter is the console_lock owner.
>>> +		 */
>>> +		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
> 
> The cross-release feature might be needed here. The above annotation
> says that the semaphore is release here. In reality, it is released

Yeah, cross-release might be needed here, but it won't be such
simple anyway.

> in the process that calls vprintk_emit(). We actually just passed the
> ownership here.
> 
> Does this make any sense? Could we do better using the existing
> lockdep annotations?

I wonder what you think about thinks I told you. Could you let me
know?

> If you have a better solution, it might make sense to send a patch
> on top of linux-next. There is a commit that moved these code
> into three helper functions:

I would after getting your feedback.

Thanks a lot.

>      console_lock_spinning_enable()
>      console_lock_spinning_disable_and_check()
>      console_trylock_spinning()
> 
> See
> https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/commit/?h=for-4.16-console-waiter-logic&id=c162d5b4338d72deed61aa65ed0f2f4ba2bbc8ab
> 
> Best Regards,
> Petr
> 
>>> +		printk_safe_exit_irqrestore(flags);
>>> +		/* Note, if waiter is set, logbuf_lock is not held */
>>> +		return;
>>> +	}
>>> +
>>>    	console_locked = 0;
>>>    	/* Release the exclusive_console once it is used */
>>>
>>
>> -- 
>> Thanks,
>> Byungchul
> 

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
