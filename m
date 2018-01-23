Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA5D0800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 11:01:59 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y62so486604pgy.0
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:01:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a33-v6sor1299695pla.91.2018.01.23.08.01.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 08:01:57 -0800 (PST)
Date: Wed, 24 Jan 2018 01:01:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180123160153.GC429@tigerII.localdomain>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123104121.2ef96d81@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/23/18 10:41), Steven Rostedt wrote:
[..]
> We can have more. But if printk is causing printks, that's a major bug.
> And work queues are not going to fix it, it will just spread out the
> pain. Have it be 100 printks, it needs to be fixed if it is happening.
> And having all printks just generate more printks is not helpful. Even
> if we slow them down. They will still never end.

Dropping the messages is not the solution either. The original bug report
report was - this "locks up my kernel". That's it. That's all people asked
us to solve.

With WQ we don't lockup the kernel, because we flush printk_safe in
preemptible context. And people are very much expected to fix the
misbehaving consoles. But that should not be printk_safe problem.

> A printk causing a printk is a special case, and we need to just show
> enough to let the user know that its happening, and why printks are
> being throttled. Yes, we may lose data, but if every printk that goes
> out causes another printk, then there's going to be so much noise that
> we wont know what other things went wrong. Honestly, if someone showed
> me a report where the logs were filled with printks that caused
> printks, I'd stop right there and tell them that needs to be fixed
> before we do anything else. And if that recursion is happening because
> of another problem, I don't want to see the recursion printks. I want
> to see the printks that show what is causing the recursions.

I'll re-read this one tomorrow. Not quite following it.

> > The problem is - we flush printk_safe too soon and printing CPU ends up
> > in a lockup - it log_store()-s new messages while it's printing the pending
> 
> No, the problem is that printks are causing more printks. Yes that will
> make flushing them soon more likely to lock up the system. But that's
> not the problem. The problem is printks causing printks.

Yes. And ignoring those printk()-s by simply dropping them does not fix
the problem by any means.

> > ones. It's fine to do so when CPU is in preemptible context. Really, we
> > should not care in printk_safe as long as we don't lockup the kernel. The
> > misbehaving console must be fixed. If CPU is not in preemptible context then
> > we do lockup the kernel. Because we flush printk_safe regardless of the
> > current CPU context. If we will flush printk_safe via WQ then we automatically
> 
> And if we can throttle recursive printks, then we should be able to
> stop that from happening.

pintk_safe was designed to be recursive. It was never designed to be
used to troubleshoot or debug consoles. But it was designed to be
recursive - because that's the sort of the problems it was meant to
handle: recursive printks that would otherwise deadlock us. That's why
we have it in the first place.

> > add this "OK! The CPU is preemptible, we can log_store(), it's totally OK, we
> > will not lockup it up." thing. Yes, we fill up the logbuf with probably needed
> > and appreciated or unneeded messages. But we should not care in printk_safe.
> > We don't lockup the kernel... And the misbehaving console must be fixed.
> 
> I agree.

Good.

> > I disagree with "If we are having issues with irq_work, we are going to have
> > issues with a work queue". There is a tremendous difference between irq_work
> > on that CPU and queue_work_on(smp_proessor_id()). One does not care about CPU
> > context, the other one does.
> 
> But switching to work queue does not address the underlining problem
> that printks are causing more printks.

The only way to address those problems is to fix the console. That's the only.

But that's not what I'm doing with my proposal. I fix the lockup scenario, the
only reported problem so far. Whilst also keeping printk_safe around.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
