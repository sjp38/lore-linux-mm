Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E97FC6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:34:55 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id c185so160593qke.14
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:34:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a45sor12386105qta.151.2018.01.10.11.34.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 11:34:55 -0800 (PST)
Date: Wed, 10 Jan 2018 11:34:51 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110193451.GB3460072@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180110181252.GK3668920@devbig577.frc2.facebook.com>
 <20180110134157.1c3ce4b9@vmware.local.home>
 <20180110185747.GO3668920@devbig577.frc2.facebook.com>
 <20180110141758.1f88e1a0@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110141758.1f88e1a0@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Wed, Jan 10, 2018 at 02:17:58PM -0500, Steven Rostedt wrote:
> > I'm not really sure why punting to a safe context is necessarily
> > unacceptable in terms of #1 because there seems to be a pretty wide
> > gap between printing useful messages synchronously and a system being
> > caught in printk flush to the point where the system is not
> > operational at all.
> 
> And what do you define as a "safe" context. And what happens when the
> system is hosed and that "safe" context no longer exists? How do you
> know that the safe context is gone?

Hmm.. yeah, we have that problem now too.  Panic bypassing
synchronizations solves some of that I guess.

> I admit now that the OOM net console bug is a real issue. But my
> saying that you were being unrealistic was more about that module you
> posted to try to demonstrate the issue.

Heh, our recollections would differ widely there, but let's leave it
at that.

> Right now my focus is an incremental approach. I'm not trying to solve
> all issues that printk has. I've focused on a single issue, and that is
> that printk is unbounded. Coming from a Real Time background, I find
> that is a big problem. I hate unbounded algorithms. I looked at this
> and found a way to make printk have a max bounded time it can print.
> Sure, it can be more than what you want, but it is a constant time,
> that can be measured. Hence, it is an O(1) solution.

It is bound iff there are contexts which can bounce the flushing role
among them, right?

> Now, if there is still issues with printk, there may be cases where
> offloading makes sense. I don't see why we should stop my solution
> because we are not addressing these other issues where offloading may
> make sense. My solution is simple, and does not impact other solutions.
> It may even show that other solutions are not needed. But that's a good
> thing.
> 
> I'm not against an offloading solution if it can solve issues without
> impacting the other printk use cases. I'm currently only focusing on
> this solution which you are fighting me against.

Oh yeah, sure.  It might actually be pretty simple to combine into
your solution.  For example, can't we just always make sure that
there's at least one sleepable context which participates in your
pingpongs, which only kicks in when a particular context is trapped
too long?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
