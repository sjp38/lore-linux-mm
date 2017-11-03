Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0E696B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 00:09:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g6so1963093pgn.11
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 21:09:58 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r26si4956033pge.200.2017.11.02.21.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 21:09:57 -0700 (PDT)
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
References: <20171102134515.6eef16de@gandalf.local.home>
 <82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9f3bbbab-ef58-a2a6-d4c5-89e62ade34f8@nvidia.com>
Date: Thu, 2 Nov 2017 21:09:32 -0700
MIME-Version: 1.0
In-Reply-To: <82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 11/02/2017 03:16 PM, Vlastimil Babka wrote:
> On 11/02/2017 06:45 PM, Steven Rostedt wrote:
> ...>  	__DEVKMSG_LOG_BIT_ON = 0,
>>  	__DEVKMSG_LOG_BIT_OFF,
>> @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility
>>  		 * semaphore.  The release will print out buffers and wake up
>>  		 * /dev/kmsg and syslog() users.
>>  		 */
>> -		if (console_trylock())
>> +		if (console_trylock()) {
>>  			console_unlock();
>> +		} else {
>> +			struct task_struct *owner = NULL;
>> +			bool waiter;
>> +			bool spin = false;
>> +
>> +			printk_safe_enter_irqsave(flags);
>> +
>> +			raw_spin_lock(&console_owner_lock);
>> +			owner = READ_ONCE(console_owner);
>> +			waiter = READ_ONCE(console_waiter);
>> +			if (!waiter && owner && owner != current) {
>> +				WRITE_ONCE(console_waiter, true);
>> +				spin = true;
>> +			}
>> +			raw_spin_unlock(&console_owner_lock);
>> +
>> +			/*
>> +			 * If there is an active printk() writing to the
>> +			 * consoles, instead of having it write our data too,
>> +			 * see if we can offload that load from the active
>> +			 * printer, and do some printing ourselves.
>> +			 * Go into a spin only if there isn't already a waiter
>> +			 * spinning, and there is an active printer, and
>> +			 * that active printer isn't us (recursive printk?).
>> +			 */
>> +			if (spin) {
>> +				/* We spin waiting for the owner to release us */
>> +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
>> +				/* Owner will clear console_waiter on hand off */
>> +				while (!READ_ONCE(console_waiter))
> 
> This should not be negated, right? We should spin while it's true, not
> false.
> 

Vlastimil's right about the polarity problem above, but while I was trying
to verify that, I noticed another problem: the "handoff" of the console lock
is broken.

For example, if there are 3 or more threads, you can do the following:

thread A: holds the console lock, is printing, then moves into the console_unlock
          phase

thread B: goes into the waiter spin loop above, and (once the polarity is corrected)
          waits for console_waiter to become 0

thread A: finishing up, sets console_waiter --> 0

thread C: before thread B notices, thread C goes into the "else" section, sees that
          console_waiter == 0, and sets console_waiter --> 1. So thread C now
          becomes the waiter

thread B: gets *very* unlucky and never sees the 1 --> 0 --> 1 transition of
          console_waiter, so it continues waiting.  And now we have both B
          and C in the same spin loop, and this is now broken.

At the root, this is really due to the absence of a pre-existing "hand-off this lock"
mechanism. And this one here is not quite correct.

Solution ideas: for a true hand-off, there needs to be a bit more information
exchanged. Conceptually, a (lock-protected) list of waiters (which would 
only ever have zero or one entries) is a good way to start thinking about it.

I talked it over with Mark Hairgrove here, he suggested a more sophisticated
way of doing that sort of hand-off, using compare-and-exchange. I can turn that
into a patch if you like (I'm not as fast as some folks, so I didn't attempt to
do that right away), although I'm sure you have lots of ideas on how to do it.


thanks,
John Hubbard


>> +					cpu_relax();
>> +
>> +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
>> +				printk_safe_exit_irqrestore(flags);
>> +
>> +				/*
>> +				 * The owner passed the console lock to us.
>> +				 * Since we did not spin on console lock, annotate
>> +				 * this as a trylock. Otherwise lockdep will
>> +				 * complain.
>> +				 */
>> +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
>> +				console_unlock();
>> +				printk_safe_enter_irqsave(flags);
>> +			}
>> +			printk_safe_exit_irqrestore(flags);
>> +
>> +		}
>>  	}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
