Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDEC06B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 22:21:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p17so3758135pfh.18
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 19:21:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m10si2094454pgn.120.2018.01.11.19.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 19:21:45 -0800 (PST)
Date: Thu, 11 Jan 2018 22:21:40 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111222140.7fd89d52@gandalf.local.home>
In-Reply-To: <20180112025612.GB6419@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
	<20180112025612.GB6419@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri, 12 Jan 2018 11:56:12 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> Hi,
> 
> On (01/11/18 11:29), Steven Rostedt wrote:
> [..]
> > > - if the patch's goal is to bound (not necessarily to watchdog's threshold)
> > > the amount of time we spend in console_unlock(), then the patch is kinda
> > > overcomplicated. but no further questions in this case.  
> > 
> > It's goal is to keep printk from running amok on a single CPU like it
> > currently does. This prevents one printk from never ending. And it is
> > far from complex. It doesn't deal with "offloading". The "handover" is
> > only done to those that are doing printks. What do you do if all CPUs
> > are in "critical sections", how would a "handoff to safe" work? Will
> > the printks never get out? If the machine were to triple fault and
> > reboot, we lost all of it.  
> 
> make printk_kthread to be just one of the things that compete for
> handed off console_sem, along with other CPUs.

Are you going to make printk thread a high priority task?

> 
> > > - but if the patch's goal is to bound (to lockup threshold) the amount of
> > > time spent in console_unlock() in order to avoid lockups [uh, a reason],
> > > then the patch is rather oversimplified.  
> > 
> > It's bound to print all the information that has been added to the
> > printk buffer. You want to bound it to some "time"  
> 
> not some... it's aligned with watchdog expectations.
> which is deterministic, isn't it?

When do you start the timer? What you are trying to solve isn't a
single printk that gets stuck. Just look at Tejun's module. To trigger
what he wanted, he had to do 10,000 printks from an interrupt context.

> 
> > My method, there's really no delay between a hand off. There's always
> > an active CPU doing printing. It matches the current method which works
> > well for getting information out. A delayed approach will break  
> 
> no, not necessarily. and my previous patch set had some bits of that
> "combined offloading and hand off" behaviour. I was thinking about
> extending it further, but decided not to. - printk_kthread would spin
> on console_owner until current console_sem hand off.

Is printk_thread always running, taking up CPU cycles?

> 
> > > claiming that for any given A, B, C the following is always true
> > > 
> > > 				A * B < C
> > > 
> > > where
> > > 	A is the amount of data to print in the worst case
> > > 	B the time call_console_drivers() needs to print a single
> > > 	  char to all registered and enabled consoles
> > > 	C the watchdog's threshold
> > > 
> > > is not really a step forward.  
> > 
> > It's no different than what we have, except that we currently have A
> > being infinite. My patch makes A no longer infinite, but a constant.  
> 
> my point is - the constant can be unrealistically high. and can
> easily overlap watchdog_threshold, returning printk back to unbound
> land. IOW, if your bound is above the watchdog threshold then you
> don't have any bounds.

That makes no sense.

> 
> by example, with console=ttyS1,57600n8
> - keep increasing the watchdog_threshold until watchdog stops
>   complaining?
> or
> - keep reducing the logbuf size until it can be flushed under
>   watchdog_threshold seconds?

After playing with the module in my last email, I think your trying to
solve multiple printks, not one that is stuck. I'm solving the one that
is stuck problem, which was easily triggered by a simple (non stess
test) module.

> 
> 
> and I demonstrated how exactly we end up having a full logbuf of pending
> messages even on systems with faster consoles.

Where did you demonstrate that. There's so many emails I can't keep up.

But still, take a look at my simple module. I locked up the system
immediately with something that shouldn't have locked up the system.
And my patch fixed it. I think that speaks louder than any of our
opinions.

> 
> 
> [..]
> > Great, and there's cases that die that my patch solves. Lets add my
> > patch now since it is orthogonal to an offloading approach and see how
> > it works, because it would solve issues that I have hit. If you can
> > show that this isn't good enough we can add another approach.  
> 
> it bounds printk. yes, good! that's what I want. but it bounds it to a
> wrong value. I want more deterministic and close to reality bound.
> and I also want to get rid of "the last console_sem owner prints it all"
> thing. I demonstrated with the traces how that thing can bite.

I have not seen any realistic traces, but perhaps I missed something. It
all requires lots of printks, in weird scenarios. I demonstrated that
the system can be locked up with few printks (one per cpu per
millisecond), and my patch solves it.

> 
> 
> > Honestly, I don't see why you are against this patch.  
> 
> prove it! show me exactly when and where I said that I NACK or
> block the patch? seriously.

Why are we having this discussion then? Just give your Ack to my patch,
and we can look to see if we need to improve on it.

> 
> 
> > It doesn't stop your work.  
> 
> and I never said it would. your patch changes nothing on my side, that's
> my message. as of now I have out-of-tree patches, well I'll keep using
> them. nothing new.
> 
> 
> > If this patch isn't enough  
> 
> BINGO! this is all I'm trying to say.
> and the only reply (if there is any at all!) I'm getting is
> "GTFO!!! your problems are unrealistic! we gonna release the
> patch and wait for someone to come along and say us something
> new about printk issues. but not you!".

I think we are misunderstanding each other. It didn't seem that you
were on board with this patch. Why didn't you just say, "here's my ack
for this patch, but we are going to need more"?

This could just be that we are misunderstanding each other. I've been
saying from the beginning, that my patch is an incremental approach.
But I never got the "OK" from you about it. You just pointed out what
you thought was its short comings. Yes, you never actually NACK'd it
(like Tejun did), but you never gave it your blessing either.

> 
> 
> > (but it does fix some issues)  
> 
> obviously there are cases which your patch addresses. have I ever
> denied that? but, once again, obviously, there are cases which it
> doesn't. and those cases tend to bite my setups. I have repeated
> it many times, and have explained in great details which parts I'm
> talking about.

Well, I could argue that the cases you are trying to solve were
intensified by the bug my patch fixes.

> 
> and I have never run unrealistic test_printk.ko against your patch
> or anything alike; why the heck would I do that.
> 
> 
> > Really, it sounds like you are afraid of this patch, that it might
> > be good enough for most cases which would make adding another approach
> > even more difficult.  
> 
> LOL! wish I knew how to capture screenshots on Linux!


OK, if you are fine with my patch, just give it an Ack, and we push it
into the wild and see what happens. If things go as you say, not good
enough, then we can add your approach. I never veered from this. It
just appeared that you didn't want this patch to go in without your
additions.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
