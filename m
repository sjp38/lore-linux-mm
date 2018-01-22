Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBE1C800D8
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 21:32:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a9so7684729pff.0
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 18:32:00 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i68si14896785pfa.238.2018.01.21.18.31.58
        for <linux-mm@kvack.org>;
        Sun, 21 Jan 2018 18:31:59 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
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
 <45bc7a00-2f7f-3319-bfed-e7b9cd7a8571@lge.com>
 <20180118222753.3e3932be@vmware.local.home>
Message-ID: <438c325f-eff4-960e-7c6b-56c7a4579050@lge.com>
Date: Mon, 22 Jan 2018 11:31:57 +0900
MIME-Version: 1.0
In-Reply-To: <20180118222753.3e3932be@vmware.local.home>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On 1/19/2018 12:27 PM, Steven Rostedt wrote:
> On Fri, 19 Jan 2018 11:37:13 +0900
> Byungchul Park <byungchul.park@lge.com> wrote:
> 
>> On 1/19/2018 12:21 AM, Steven Rostedt wrote:
>>> On Thu, 18 Jan 2018 13:01:46 +0900
>>> Byungchul Park <byungchul.park@lge.com> wrote:
>>>    
>>>>> I disagree. It is like a spinlock. You can say a spinlock() that is
>>>>> blocked is also waiting for an event. That event being the owner does a
>>>>> spin_unlock().
>>>>
>>>> That's exactly what I was saying. Excuse me but, I don't understand
>>>> what you want to say. Could you explain more? What do you disagree?
>>>
>>> I guess I'm confused at what you are asking for then.
>>
>> Sorry for not enough explanation. What I asked you for is:
>>
>>      1. Relocate acquire()s/release()s.
>>      2. So make it simpler and remove unnecessary one.
>>      3. So make it look like the following form,
>>         because it's a thing simulating "wait and event".
>>
>>         A context
>>         ---------
>>         lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
>>                                 /* "Read" one is better though..    */
> 
> why? I'm assuming you are talking about adding this to the current

It was about console_unlock()'s body that is:

+        /* The waiter may spin on us after setting console_owner */
+        spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
          ^^^^^^^^^^^^
+
          stop_critical_timings();    /* don't trace print latency */
          call_console_drivers(ext_text, ext_len, text, len);
          start_critical_timings();
+
+        raw_spin_lock(&console_owner_lock);
+        waiter = READ_ONCE(console_waiter);
+        console_owner = NULL;
+        raw_spin_unlock(&console_owner_lock);
+
+        /*
+         * If there is a waiter waiting for us, then pass the
+         * rest of the work load over to that waiter.
+         */
+        if (waiter)
+            break;
+
+        /* There was no waiter, and nothing will spin on us here */
+        spin_release(&console_owner_dep_map, 1, _THIS_IP_);
          ^^^^^^^^^^^^ I recommand to move this over the "if" statament.
+
          printk_safe_exit_irqrestore(flags);
          if (do_cond_resched)
              cond_resched();
      }
+
+    /*
+     * If there is an active waiter waiting on the console_lock.
+     * Pass off the printing to the waiter, and the waiter
+     * will continue printing on its CPU, and when all writing
+     * has finished, the last printer will wake up klogd.
+     */
+    if (waiter) {
+        WRITE_ONCE(console_waiter, false);
+        /* The waiter is now free to continue */
+        spin_release(&console_owner_dep_map, 1, _THIS_IP_);
          ^^^^^^^^^^^^ I recommand to remove this.

> owner off the console_owner? This is a mutually exclusive section, no
> parallel access. Why the Read?

Not much matter whether to use the read version or not.

Let me explain it more since you asked. (I don't stongly insist to use
the read version tho.) For example:

       A context (context A)
       ---------------------
       lock_map_acquire(wait); /* Or lock_map_acquire_read(wait) */
                               /* "Read" one is better though..    */

       /* A section, we suspect a wait for the event might happen. */
       ...

       lock_map_release(wait);
       trigger the event;

       The place actually doing the wait (context B)
       ---------------------------------------------
       lock_map_acquire(wait);
       lock_map_release(wait);

       wait_for_event(wait); /* Actually do the wait */

The acquire() in context A is not a real acquisition but only for
detecting if a wait is in the section, which means that should not
interact with another pseudo acqusition but only with real waits.

lock_map_acquire_read() makes it done as we expect. That's why I
said 'read' one is better. But it's ok to use normal(write) one.
(I'm not sure if Peterz finished making the 'read' work well, tho.)

>>
>>         /* A section, we suspect a wait for an event might happen. */
>>         ...
>>
>>         lock_map_release(wait);
>>
>>         The place actually doing the wait
>>         ---------------------------------
>>         lock_map_acquire(wait);
>>         lock_map_release(wait);
>>
>>         wait_for_event(wait); /* Actually do the wait */
>>
>> Honestly, you used acquire()s/release()s as if they are cross-
>> release stuff which mainly handles general waits and events,
>> not only things doing "acquire -> critical area -> release".
>> But that's not in the mainline at the moment.
> 
> Maybe it is more like that. Because, the thing I'm doing is passing off
> a semaphore ownership to the waiter.
> 
>  From a previous email:
> 
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
> There is no acquisitions between acquire and release. To get to
> "if (spin)" the acquire had to already been done. If it was released,
> this spinner is now the new "owner". There's no race with anyone else.
> But it doesn't technically have it till console_waiter is set to NULL.
> Why would we call release() before that? Or maybe I'm missing something.
> 
> Or are you just saying that it doesn't matter if it is before or after
> the while() loop, to just put it before? Does it really matter?

It doesn't matter. As I said, there's logically no problem on it.
Leave the code if you want to locate those that way. I just started
to mention it becasue some lines can be removed with the code a bit
fixed.

> 
> -- Steve
> 

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
