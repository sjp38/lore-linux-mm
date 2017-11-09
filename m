Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8EE6440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 00:07:03 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id f20so7750685ioj.2
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 21:07:03 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0134.hostedemail.com. [216.40.44.134])
        by mx.google.com with ESMTPS id r2si4841369ioa.54.2017.11.08.21.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 21:07:02 -0800 (PST)
Date: Thu, 9 Nov 2017 00:06:58 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171109000658.7df5a791@vmware.local.home>
In-Reply-To: <20171109044548.GC775@jagdpanzerIV>
References: <20171102134515.6eef16de@gandalf.local.home>
	<201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
	<20171107014015.GA1822@jagdpanzerIV>
	<20171108051955.GA468@jagdpanzerIV>
	<20171108092951.4d677bca@gandalf.local.home>
	<20171109005635.GA775@jagdpanzerIV>
	<20171108222905.426fc73a@vmware.local.home>
	<20171109044548.GC775@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

On Thu, 9 Nov 2017 13:45:48 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

>
> so what we are looking at
> 
>    a) we take over printing. can be from safe context to unsafe context
>       [well, bad karma]. can be from unsafe context to a safe one. or from
>       safe context to another safe context... or from one unsafe context to
>       another unsafe context [bad karma again]. we really never know, no
>       one does.
> 
>       lots of uncertainties - "may be X, may be Y, may be Z". a bigger
>       picture: we still can have the same lockup scenarios as we do
>       have today.
> 
>       and we also bring busy loop with us, so the new console_sem
>       owner [regardless its current context] CPU must wait until the
>       current console_sem finishes its call_console_drivers(). I
>       mentioned it in my another email, you seemed to jump over that
>       part. was it irrelevant or wrong?
> 
> vs.
> 
>    b) we offload to printk_kthread [safe context].
> 
> 
> why (a) is better than (b)?
> 


What does safe context mean? Do we really want to allow the printk
thread to sleep when there's more to print? What happens if there's a
crash at that moment? How do we safely flush out all the data when the
printk thread is sleeping?

Now we could have something that uses both nicely. When the
printk_thread wakes up (we need to figure out when to do that), then it
could constantly take over.


	CPU1				CPU2
	----				----
   console_unlock()
     start printing a lot
     (more than one, wake up printk_thread)

					printk thread wakes up

					becomes the waiter

   sees waiter hands off

					starts printing

   printk()
     becomes waiter

					sees waiter hands off
					then becomes new waiter! <-- key

    starts printing
    sees waiter hands off
					continues printing


That is, we keep the waiter logic, and if anyone starts printing too
much, it wakes up the printk thread (hopefully on another CPU, or the
printk thread should migrate)  when the printk thread starts running it
becomes the new waiter if the console lock is still held (just like in
printk). Then it gets handed off the printk. We could just have the
printk thread keep going, though I'm not sure I would want to let it
schedule while printing. But it could also hand off printks (like
above), but then take it back immediately. This would mean that a
printk caller from a "critical" path will only get to do one message,
before the printk thread asks for it again.

Perhaps we could have more than one printk thread that migrates around,
and they each hand off the printing. This makes sure the printing
always happens and that it never stops due to the console_lock holder
sleeping and we never lock up one CPU that does printing. This would
work with just two printk threads. When one starts a printk loop,
another one wakes up on another CPU and becomes the waiter to get the
handoff of the console_lock. Then the first could schedule out (migrate
if the current CPU is busy), and take over. In  fact, this would
basically have two CPUs bouncing back and forth to do the printing.

This gives us our cake and we get to eat it too.

One, printing never stops (no scheduling out), as there's two threads
to share the load (obiously only on SMP machines).

There's no lock up. There's two threads that print a little, pass off
the console lock, do a cond_resched(), then takes over again.

Bascially, what I'm saying is that this is not two different solutions.
There is two algorithms that can work together to give us reliable
output and not lock up the system in doing so.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
