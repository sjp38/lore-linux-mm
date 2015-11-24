Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5576B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 08:30:21 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so12811649obb.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:30:20 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id l72si10773164oib.49.2015.11.24.05.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 05:30:20 -0800 (PST)
Received: by obbbj7 with SMTP id bj7so12845994obb.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:30:20 -0800 (PST)
Message-ID: <56546669.30006@acm.org>
Date: Tue, 24 Nov 2015 07:30:17 -0600
From: Corey Minyard <minyard@acm.org>
Reply-To: minyard@acm.org
MIME-Version: 1.0
Subject: Re: [PATCH v3 17/22] ipmi: Convert kipmi kthread into kthread worker
 API
References: <1447853127-3461-1-git-send-email-pmladek@suse.com> <1447853127-3461-18-git-send-email-pmladek@suse.com> <56536AA6.5040102@acm.org> <20151124121233.GH10750@pathway.suse.cz>
In-Reply-To: <20151124121233.GH10750@pathway.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, openipmi-developer@lists.sourceforge.net

On 11/24/2015 06:12 AM, Petr Mladek wrote:
> On Mon 2015-11-23 13:36:06, Corey Minyard wrote:
>>
>> On 11/18/2015 07:25 AM, Petr Mladek wrote:
>>> Kthreads are currently implemented as an infinite loop. Each
>>> has its own variant of checks for terminating, freezing,
>>> awakening. In many cases it is unclear to say in which state
>>> it is and sometimes it is done a wrong way.
>>>
>>> The plan is to convert kthreads into kthread_worker or workqueues
>>> API. It allows to split the functionality into separate operations.
>>> It helps to make a better structure. Also it defines a clean state
>>> where no locks are taken, IRQs blocked, the kthread might sleep
>>> or even be safely migrated.
>>>
>>> The kthread worker API is useful when we want to have a dedicated
>>> single thread for the work. It helps to make sure that it is
>>> available when needed. Also it allows a better control, e.g.
>>> define a scheduling priority.
>>>
>>> This patch converts kipmi kthread into the kthread worker API because
>>> it modifies the scheduling priority. The change is quite straightforward.
>> I think this is correct.  That code was hard to get right, but I don't
>> see where any
>> logic is actually changed.
> I believe that it was hard to make it working.
>
>
>> This also doesn't really look any simpler (you end up with more LOC than
>> you did before :) ),
>> though it will make things more consistent and reduce errors and that's
>> a good thing.
> I have just realized that the original code actually looks racy. For
> example, it does:
>
> 	__set_current_state(TASK_INTERRUPTIBLE);
> 	schedule();
>
> without rechecking the state in between. There might already be a new
> message and it might miss the wake_up_process(). Similar problem is
> with the schedule_timeout_interruptible(100); I mean:
>
>
> CPU 0					CPU 1
>
>
> ipmi_thread()
>   spin_lock_irqsave();
>   smi_result = smi_event_handler();
>   spin_unlock_irqrestore();
>
>   [...]
>   else if (smi_result == SI_SM_IDLE)
>     /* true */
>     if (atomic_read(need_watch)) {
>       /* true */
>
> 					sender()
> 					  spin_lock_irqsave()
> 					  check_start_timer_thread()
> 					    wake_up_process()
>
> 					    /*
> 					     * NOPE because kthread
> 					     * is not sleeping
> 					     */
>
>      schedule_timeout_interruptible(100);
>
>      /*
>       * We sleep 100 jiffies but
>       * there is a pending message.
>       */

Yes, I knew the code was racy, but this is a performance optimization and
it wasn't that important to get it perfect.  The thread wouldn't actually
wait 100 jiffies, it would just be run by timer interrupts for that time.

>
> This is not a problem with the kthread worker API because
>
> 	mod_delayed_kthread_work(smi_info->worker,
> 				 &smi_info->work, 0);
>
> would queue the work to be done immediately and
>
> 	queue_delayed_kthread_work(smi_info->worker,
> 				   &smi_info->work, 100);
>
> would do nothing in this case.

And indeed this is a lot better.

>
>> My only comment is I would like the worker function named ipmi_worker,
>> not ipmi_func.
> You probably want it because the original name was ipmi_thread. But
> it might cause confusion with new_smi->worker. The function gets
> assigned to work->func, see struct kthread_work. Therefore I think that
> _func suffix makes more sense.

My problem with _func is that it's way too generic.  Is this a function
that handled IPMI messages?  Message done handling?  I'm not enamored
with my name, but I want something that gives a better indication of
what the function does.  ipmi_kthread_worker_func() would be fine with me.

Thanks,

-corey

>> Reviewed-by: Corey Minyard <cminyard@mvista.com>
>
> Thanks a lot for review,
> Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
