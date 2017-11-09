Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4E9440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 00:34:05 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id o7so5002618pgc.23
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 21:34:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h3sor1920136plh.115.2017.11.08.21.34.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 21:34:04 -0800 (PST)
Date: Thu, 9 Nov 2017 14:33:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171109053358.GD775@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
 <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
 <20171107014015.GA1822@jagdpanzerIV>
 <20171108051955.GA468@jagdpanzerIV>
 <20171108092951.4d677bca@gandalf.local.home>
 <20171109005635.GA775@jagdpanzerIV>
 <20171108222905.426fc73a@vmware.local.home>
 <20171109044548.GC775@jagdpanzerIV>
 <20171109000658.7df5a791@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171109000658.7df5a791@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

On (11/09/17 00:06), Steven Rostedt wrote:
> What does safe context mean?

"safe" means that we don't cause lockups, stalls, sched throttlings, etc.
by doing console_unlock() from that context [task].


> Do we really want to allow the printk thread to sleep when there's more
> to print? What happens if there's a crash at that moment? How do we safely
> flush out all the data when the printk thread is sleeping?

printk-kthread does not schedule with the console_sem locked. one
of the changes to console_unlock() introduced with printk-kthread,
which we can't have without offloading.


> Now we could have something that uses both nicely. When the
> printk_thread wakes up (we need to figure out when to do that), then it
> could constantly take over.

certainly we can have a better hand-off scheme in printk-kthread patch set.


> 
> 	CPU1				CPU2
> 	----				----
>    console_unlock()
>      start printing a lot
>      (more than one, wake up printk_thread)
> 
> 					printk thread wakes up
> 
> 					becomes the waiter
> 
>    sees waiter hands off
> 
> 					starts printing
> 
>    printk()
>      becomes waiter
> 
> 					sees waiter hands off
> 					then becomes new waiter! <-- key
> 
>     starts printing
>     sees waiter hands off
> 					continues printing

there are corners cases here. learned the hard way. real reproducers
do exist.

wake_up_process() may enqueue printk_thread on the same rq that
current printk task is running on. so if your printk(), for instance,
is from IRQ then offloading won't happen.


> That is, we keep the waiter logic, and if anyone starts printing too
> much, it wakes up the printk thread (hopefully on another CPU, or the
> printk thread should migrate)  when the printk thread starts running it

it must migrate, yes. currently I'm playing games with the affinity
mask of printk-kthread when I do offloading.


> becomes the new waiter if the console lock is still held (just like in
> printk). Then it gets handed off the printk. We could just have the
> printk thread keep going, though I'm not sure I would want to let it
> schedule while printing. 

yes, scheduling under console_sem is not right. we don't want this.
not anymore, at least.


> But it could also hand off printks (like
> above), but then take it back immediately. This would mean that a
> printk caller from a "critical" path will only get to do one message,
> before the printk thread asks for it again.
> 
> Perhaps we could have more than one printk thread that migrates around,
> and they each hand off the printing. This makes sure the printing
> always happens and that it never stops due to the console_lock holder
> sleeping and we never lock up one CPU that does printing. This would
> work with just two printk threads. When one starts a printk loop,
> another one wakes up on another CPU and becomes the waiter to get the
> handoff of the console_lock. Then the first could schedule out (migrate
> if the current CPU is busy), and take over. In  fact, this would
> basically have two CPUs bouncing back and forth to do the printing.

can be. I pushed it much further, once. [probably too far].
and had per-CPU printk-kthreads :)


> This gives us our cake and we get to eat it too.
> 
> One, printing never stops (no scheduling out), as there's two threads
> to share the load (obiously only on SMP machines).
> 
> There's no lock up. There's two threads that print a little, pass off
> the console lock, do a cond_resched(), then takes over again.
> 
> Bascially, what I'm saying is that this is not two different solutions.
> There is two algorithms that can work together to give us reliable
> output and not lock up the system in doing so.

sure, I understand.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
