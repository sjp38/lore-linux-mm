Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFA986B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:55:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 5so2665956wmk.13
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:55:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si2709088edi.302.2017.11.02.05.55.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:55:30 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:55:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
Message-ID: <20171102125528.4upg5eaw7cgxmak6@dhcp22.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171031153225.218234b4@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031153225.218234b4@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Tue 31-10-17 15:32:25, Steven Rostedt wrote:
> 
> Thank you for the perfect timing. You posted this the day after I
> proposed a new solution at Kernel Summit in Prague for the printk lock
> loop that you experienced here.
> 
> I attached the pdf that I used for that discussion (ignore the last
> slide, it was left over and I never went there).
> 
> My proposal is to do something like this with printk:
> 
> Three types of printk usages:
> 
> 1) Active printer (actively writing to the console).
> 2) Waiter (active printer, first user)
> 3) Sees active printer and a waiter, and just adds to the log buffer
>    and leaves.
> 
> (new globals)
> static DEFINE_SPIN_LOCK(console_owner_lock);
> static struct task_struct console_owner;
> static bool waiter;
> 
> console_unlock() {
> 
> [ Assumes this part can not preempt ]
> 
> 	spin_lock(console_owner_lock);
> 	console_owner = current;
> 	spin_unlock(console_owner_lock);
> 
> 	for each message
> 		write message out to console
> 
> 		if (READ_ONCE(waiter))
> 			break;
> 
> 	spin_lock(console_owner_lock);
> 	console_owner = NULL;
> 	spin_unlock(console_owner_lock);
> 
> [ preemption possible ]
> 
> 	[ Needs to make sure waiter gets semaphore ]
> 
> 	up(console_sem);
> }
> 
> 
> Then printk can have something like:
> 
> 
> 	if (console_trylock())
> 		console_unlock();
> 	else {
> 		struct task_struct *owner = NULL;
> 
> 		spin_lock(console_owner_lock);
> 		if (waiter)
> 			goto out;
> 		WRITE_ONCE(waiter, true);
> 		owner = READ_ONCE(console_owner);		
> 	out:
> 		spin_unlock(console_owner_lock);
> 		if (owner) {
> 			while (!console_trylock())	
> 				cpu_relax();
> 			spin_lock(console_owner_lock);
> 			waiter = false;
> 			spin_unlock(console_owner_lock);
> 		}
> 	}
> 
> This way, only one CPU spins waiting to print, and only if the
> console_lock owner is actively printing. If the console_lock owner
> notices someone is waiting to print, it stops printing as a waiter will
> always continue the prints. This will balance out the printks among all
> the CPUs that are doing them and no one CPU will get stuck doing all
> the printks.
> 
> This would solve your issue because the next warn_alloc() caller would
> become the waiter, and take over the next message in the queue. This
> would spread out the load of who does the actual printing, and not have
> one printer be stuck doing the work.

That also means that we would shift the overhead only to the first
waiter AFAIU. What if we have floods of warn_alloc from all CPUs?
Something that Tetsuo's test case simulates.

As Petr pointed out earlier in the thread, I do not think this is going
to help cosiderably and offloading to a kernel thread sounds like a
more viable option. It sounds really wrong to have printk basically
indeterministic wrt. call duration depending on who happens to do the
actual work. Either we make the call sync or completely offloaded to
a dedicated kernel thread and make sure that the buffer gets flushed
unconditionally on panic. I haven't been following all the printk
discussion recently so maybe this has been discussed and deemed not
viable for implementation details but in principle this should work.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
