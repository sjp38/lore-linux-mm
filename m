Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92A74800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 11:24:42 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id h12so555409oti.16
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:24:42 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e5si227563ote.62.2018.01.23.08.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 08:24:40 -0800 (PST)
Date: Tue, 23 Jan 2018 11:24:36 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123112436.0c94bc2e@gandalf.local.home>
In-Reply-To: <20180123160153.GC429@tigerII.localdomain>
References: <20180117121251.7283a56e@gandalf.local.home>
	<20180117134201.0a9cbbbf@gandalf.local.home>
	<20180119132052.02b89626@gandalf.local.home>
	<20180120071402.GB8371@jagdpanzerIV>
	<20180120104931.1942483e@gandalf.local.home>
	<20180121141521.GA429@tigerII.localdomain>
	<20180123064023.GA492@jagdpanzerIV>
	<20180123095652.5e14da85@gandalf.local.home>
	<20180123152130.GB429@tigerII.localdomain>
	<20180123104121.2ef96d81@gandalf.local.home>
	<20180123160153.GC429@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 24 Jan 2018 01:01:53 +0900
Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> On (01/23/18 10:41), Steven Rostedt wrote:
> [..]
> > We can have more. But if printk is causing printks, that's a major bug.
> > And work queues are not going to fix it, it will just spread out the
> > pain. Have it be 100 printks, it needs to be fixed if it is happening.
> > And having all printks just generate more printks is not helpful. Even
> > if we slow them down. They will still never end.  
> 
> Dropping the messages is not the solution either. The original bug report
> report was - this "locks up my kernel". That's it. That's all people asked
> us to solve.

And throttling the printks would stop the lock up too.

> 
> With WQ we don't lockup the kernel, because we flush printk_safe in
> preemptible context. And people are very much expected to fix the
> misbehaving consoles. But that should not be printk_safe problem.

Right, but now you just made printk safe unreliable to get information
out, because you need to wait for a schedule to occur, and if there's
issues, like a deadlock, that thread will never run. And you just lost
you lockdep splat.

> 
> > A printk causing a printk is a special case, and we need to just show
> > enough to let the user know that its happening, and why printks are
> > being throttled. Yes, we may lose data, but if every printk that goes
> > out causes another printk, then there's going to be so much noise that
> > we wont know what other things went wrong. Honestly, if someone showed
> > me a report where the logs were filled with printks that caused
> > printks, I'd stop right there and tell them that needs to be fixed
> > before we do anything else. And if that recursion is happening because
> > of another problem, I don't want to see the recursion printks. I want
> > to see the printks that show what is causing the recursions.  
> 
> I'll re-read this one tomorrow. Not quite following it.

I'll add more capitals next time ;-)

> 
> > > The problem is - we flush printk_safe too soon and printing CPU ends up
> > > in a lockup - it log_store()-s new messages while it's printing the pending  
> > 
> > No, the problem is that printks are causing more printks. Yes that will
> > make flushing them soon more likely to lock up the system. But that's
> > not the problem. The problem is printks causing printks.  
> 
> Yes. And ignoring those printk()-s by simply dropping them does not fix
> the problem by any means.

How so? If we drop them, then the stuck printk has nothing to print and
will move forward.

I say once you start dropping printks due to recursion, keep dropping
them. For at least a second, to allow them to stop killing the machine.

> 
> > > ones. It's fine to do so when CPU is in preemptible context. Really, we
> > > should not care in printk_safe as long as we don't lockup the kernel. The
> > > misbehaving console must be fixed. If CPU is not in preemptible context then
> > > we do lockup the kernel. Because we flush printk_safe regardless of the
> > > current CPU context. If we will flush printk_safe via WQ then we automatically  
> > 
> > And if we can throttle recursive printks, then we should be able to
> > stop that from happening.  
> 
> pintk_safe was designed to be recursive. It was never designed to be
> used to troubleshoot or debug consoles. But it was designed to be
> recursive - because that's the sort of the problems it was meant to
> handle: recursive printks that would otherwise deadlock us. That's why
> we have it in the first place.

So printk safe is only triggered when at the same context? If we can
guarantee that printk safe is triggered only when its because a printk
is happening at the same context (not because of an interrupt, but
really at the same context, using my context check), then I'm fine with
delaying them to a work queue.

That is, if we have this:

	printk()
		console_lock()
			<interrupt>
				printk()
					add to log buffer
		<print irq printk too>
		console_unlock();


	printk()
		console_lock()
			<console does a printk>
				put in printk safe buffer
				trigger work queue
		console_unlock()
	<work queue>
		flush safe buffer
		printk()

Then I'm fine with that.

I have to look at the latest code. If this is indeed what we have, then
I admit I misunderstood the problem you want to solve.

I only want recursive printks (those that are actually triggered by
doing a printk) to be allowed to be delayed.

Make sense?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
