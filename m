Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 114176B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 14:18:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o9so91966pgv.3
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:18:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3si12481113pln.509.2018.01.10.11.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 11:18:01 -0800 (PST)
Date: Wed, 10 Jan 2018 14:17:58 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180110141758.1f88e1a0@vmware.local.home>
In-Reply-To: <20180110185747.GO3668920@devbig577.frc2.facebook.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180110181252.GK3668920@devbig577.frc2.facebook.com>
	<20180110134157.1c3ce4b9@vmware.local.home>
	<20180110185747.GO3668920@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 10:57:47 -0800
Tejun Heo <tj@kernel.org> wrote:

> Hello, Steven.
> 
> On Wed, Jan 10, 2018 at 01:41:57PM -0500, Steven Rostedt wrote:
> > The issue with the solution you want to do with printk is that it can
> > break existing printk usages. As Petr said, people want printk to do two
> > things. 1 - print out data ASAP, 2 - not lock up the system. The two
> > are fighting each other. You care more about 2 where I (and others,
> > like Peter Zijlstra and Linus) care more about 1.
> > 
> > My solution can help with 2 without doing anything to hurt 1.  
> 
> I'm not really sure why punting to a safe context is necessarily
> unacceptable in terms of #1 because there seems to be a pretty wide
> gap between printing useful messages synchronously and a system being
> caught in printk flush to the point where the system is not
> operational at all.

And what do you define as a "safe" context. And what happens when the
system is hosed and that "safe" context no longer exists? How do you
know that the safe context is gone?

> 
> > You are NACKing my solution because it doesn't solve this bug with net
> > console. I believe net console should be fixed. You believe that printk
> > should have a work around to not let net console type bugs occur. Which
> > to me is papering over the real bugs.  
> 
> As I wrote along with nack, I was more concerned with how this was
> pushed forward by saying that actual problems are not real.

You mean you saying that? I never created this patch set for the
problems you reported. You came in nacking this saying that it doesn't
solve your problems and showed some totally unrealistic module that
triggers issues that my patch doesn't solve.

I admit now that the OOM net console bug is a real issue. But my
saying that you were being unrealistic was more about that module you
posted to try to demonstrate the issue.

This is not the issue I'm trying to solve, and I don't understand why
you are against my solution when it is agnostic to any solution that
you want to do as well.

One way to have an offload solution added on top of mine, is to have a
limit in how many messages the printk will do. Honestly, I believe it
should always printk its own message if there are no others trying to
do a print. Yes, that may still not solve the net console bug, but it
helps guarantee that printks get out.

But if a printk starts printing more than one message, perhaps that is
where we can look at offloading. Similar to how softirq works. If a
softirq repeats too many times, it is offloaded to the ksoftirqd
thread. We can have a similar approach to printk.

> 
> As for the netconsole part, sure, that can be one way, but please
> consider that the messages could be coming from network drivers, of
> which we have many and a lot of them aren't too high quality.  Plus,
> netconsole is a separate path and network drivers can easily
> malfunction on memory allocation failures.
> 
> Again, not a critical problem.  We can decide either way but it'd be
> better to be generally safe (if we can do that reasonably), right?

OK, lets start over.

Right now my focus is an incremental approach. I'm not trying to solve
all issues that printk has. I've focused on a single issue, and that is
that printk is unbounded. Coming from a Real Time background, I find
that is a big problem. I hate unbounded algorithms. I looked at this
and found a way to make printk have a max bounded time it can print.
Sure, it can be more than what you want, but it is a constant time,
that can be measured. Hence, it is an O(1) solution.

Now, if there is still issues with printk, there may be cases where
offloading makes sense. I don't see why we should stop my solution
because we are not addressing these other issues where offloading may
make sense. My solution is simple, and does not impact other solutions.
It may even show that other solutions are not needed. But that's a good
thing.

I'm not against an offloading solution if it can solve issues without
impacting the other printk use cases. I'm currently only focusing on
this solution which you are fighting me against.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
