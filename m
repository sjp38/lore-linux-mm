Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7646B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:45:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i1so190829pgv.22
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:45:00 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u195si4300495pgb.30.2018.01.10.11.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 11:44:58 -0800 (PST)
Date: Wed, 10 Jan 2018 14:44:55 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110144455.66fe53c9@vmware.local.home>
In-Reply-To: <20180110193451.GB3460072@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180110181252.GK3668920@devbig577.frc2.facebook.com>
	<20180110134157.1c3ce4b9@vmware.local.home>
	<20180110185747.GO3668920@devbig577.frc2.facebook.com>
	<20180110141758.1f88e1a0@vmware.local.home>
	<20180110193451.GB3460072@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 11:34:51 -0800
Tejun Heo <tj@kernel.org> wrote:

> > Right now my focus is an incremental approach. I'm not trying to solve
> > all issues that printk has. I've focused on a single issue, and that is
> > that printk is unbounded. Coming from a Real Time background, I find
> > that is a big problem. I hate unbounded algorithms. I looked at this
> > and found a way to make printk have a max bounded time it can print.
> > Sure, it can be more than what you want, but it is a constant time,
> > that can be measured. Hence, it is an O(1) solution.  
> 
> It is bound iff there are contexts which can bounce the flushing role
> among them, right?

No, not at all. The printk can only print what's in the buffer. The
buffer can only get more to print if another printk occurs. If that
happens, that other printk takes over. Thus, any single printk can
print at most one buffer full. Which is bounded to the size of the
buffer.

Yes, there can be the case that printks are added via an interrupt, but
then again, it's an issue that a single CPU. And printks from interrupt
context should be considered critical, part of the ASAP category. If
they are not critical, then they shouldn't be doing printks. That may
be a place were we can add a "printk_delay", for things like non
critical printks in interrupt context, that can trigger offloading?

> 
> > Now, if there is still issues with printk, there may be cases where
> > offloading makes sense. I don't see why we should stop my solution
> > because we are not addressing these other issues where offloading may
> > make sense. My solution is simple, and does not impact other solutions.
> > It may even show that other solutions are not needed. But that's a good
> > thing.
> > 
> > I'm not against an offloading solution if it can solve issues without
> > impacting the other printk use cases. I'm currently only focusing on
> > this solution which you are fighting me against.  
> 
> Oh yeah, sure.  It might actually be pretty simple to combine into
> your solution.  For example, can't we just always make sure that
> there's at least one sleepable context which participates in your
> pingpongs, which only kicks in when a particular context is trapped
> too long?

The solution can be extended to that if the need exists, yes.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
