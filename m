Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71CAC6B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 21:56:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d72so3650761pga.7
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 18:56:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h17sor4120313pgv.0.2018.01.11.18.56.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 18:56:18 -0800 (PST)
Date: Fri, 12 Jan 2018 11:56:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180112025612.GB6419@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111112908.50de440a@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hi,

On (01/11/18 11:29), Steven Rostedt wrote:
[..]
> > - if the patch's goal is to bound (not necessarily to watchdog's threshold)
> > the amount of time we spend in console_unlock(), then the patch is kinda
> > overcomplicated. but no further questions in this case.
> 
> It's goal is to keep printk from running amok on a single CPU like it
> currently does. This prevents one printk from never ending. And it is
> far from complex. It doesn't deal with "offloading". The "handover" is
> only done to those that are doing printks. What do you do if all CPUs
> are in "critical sections", how would a "handoff to safe" work? Will
> the printks never get out? If the machine were to triple fault and
> reboot, we lost all of it.

make printk_kthread to be just one of the things that compete for
handed off console_sem, along with other CPUs.

> > - but if the patch's goal is to bound (to lockup threshold) the amount of
> > time spent in console_unlock() in order to avoid lockups [uh, a reason],
> > then the patch is rather oversimplified.
> 
> It's bound to print all the information that has been added to the
> printk buffer. You want to bound it to some "time"

not some... it's aligned with watchdog expectations.
which is deterministic, isn't it?

> My method, there's really no delay between a hand off. There's always
> an active CPU doing printing. It matches the current method which works
> well for getting information out. A delayed approach will break

no, not necessarily. and my previous patch set had some bits of that
"combined offloading and hand off" behaviour. I was thinking about
extending it further, but decided not to. - printk_kthread would spin
on console_owner until current console_sem hand off.

> > claiming that for any given A, B, C the following is always true
> > 
> > 				A * B < C
> > 
> > where
> > 	A is the amount of data to print in the worst case
> > 	B the time call_console_drivers() needs to print a single
> > 	  char to all registered and enabled consoles
> > 	C the watchdog's threshold
> > 
> > is not really a step forward.
> 
> It's no different than what we have, except that we currently have A
> being infinite. My patch makes A no longer infinite, but a constant.

my point is - the constant can be unrealistically high. and can
easily overlap watchdog_threshold, returning printk back to unbound
land. IOW, if your bound is above the watchdog threshold then you
don't have any bounds.

by example, with console=ttyS1,57600n8
- keep increasing the watchdog_threshold until watchdog stops
  complaining?
or
- keep reducing the logbuf size until it can be flushed under
  watchdog_threshold seconds?


and I demonstrated how exactly we end up having a full logbuf of pending
messages even on systems with faster consoles.


[..]
> Great, and there's cases that die that my patch solves. Lets add my
> patch now since it is orthogonal to an offloading approach and see how
> it works, because it would solve issues that I have hit. If you can
> show that this isn't good enough we can add another approach.

it bounds printk. yes, good! that's what I want. but it bounds it to a
wrong value. I want more deterministic and close to reality bound.
and I also want to get rid of "the last console_sem owner prints it all"
thing. I demonstrated with the traces how that thing can bite.


> Honestly, I don't see why you are against this patch.

prove it! show me exactly when and where I said that I NACK or
block the patch? seriously.


> It doesn't stop your work.

and I never said it would. your patch changes nothing on my side, that's
my message. as of now I have out-of-tree patches, well I'll keep using
them. nothing new.


> If this patch isn't enough

BINGO! this is all I'm trying to say.
and the only reply (if there is any at all!) I'm getting is
"GTFO!!! your problems are unrealistic! we gonna release the
patch and wait for someone to come along and say us something
new about printk issues. but not you!".


> (but it does fix some issues)

obviously there are cases which your patch addresses. have I ever
denied that? but, once again, obviously, there are cases which it
doesn't. and those cases tend to bite my setups. I have repeated
it many times, and have explained in great details which parts I'm
talking about.

and I have never run unrealistic test_printk.ko against your patch
or anything alike; why the heck would I do that.


> Really, it sounds like you are afraid of this patch, that it might
> be good enough for most cases which would make adding another approach
> even more difficult.

LOL! wish I knew how to capture screenshots on Linux!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
