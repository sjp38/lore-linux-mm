Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 110556B026E
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 11:29:14 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o11so2613102pgp.14
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 08:29:14 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r59si1594468plb.314.2018.01.11.08.29.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 08:29:12 -0800 (PST)
Date: Thu, 11 Jan 2018 11:29:08 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111112908.50de440a@vmware.local.home>
In-Reply-To: <20180111103845.GB477@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu, 11 Jan 2018 19:38:45 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> 
> the non-atomic -> atomic context console_sem transfer. we previously
> would have kept the console_sem owner to its non-atomic owner. we now
> will make sure that if printk from atomic context happens then it will
> make it to console_unlock() loop.
> emphasis on O(logbuf) > watchdog_thresh.
> 
> 
> - if the patch's goal is to bound (not necessarily to watchdog's threshold)
> the amount of time we spend in console_unlock(), then the patch is kinda
> overcomplicated. but no further questions in this case.

It's goal is to keep printk from running amok on a single CPU like it
currently does. This prevents one printk from never ending. And it is
far from complex. It doesn't deal with "offloading". The "handover" is
only done to those that are doing printks. What do you do if all CPUs
are in "critical sections", how would a "handoff to safe" work? Will
the printks never get out? If the machine were to triple fault and
reboot, we lost all of it.

> 
> - but if the patch's goal is to bound (to lockup threshold) the amount of
> time spent in console_unlock() in order to avoid lockups [uh, a reason],
> then the patch is rather oversimplified.

It's bound to print all the information that has been added to the
printk buffer. You want to bound it to some "time" and what about the
printks that haven't gotten out yet? Delay them to something else, and
if the machine were to crash in the transfer, we lost all that data.

My method, there's really no delay between a hand off. There's always
an active CPU doing printing. It matches the current method which works
well for getting information out. A delayed approach will break that
and that's what people like myself, Peter, Linus and others are worried
about.


> 
> 
> claiming that for any given A, B, C the following is always true
> 
> 				A * B < C
> 
> where
> 	A is the amount of data to print in the worst case
> 	B the time call_console_drivers() needs to print a single
> 	  char to all registered and enabled consoles
> 	C the watchdog's threshold
> 
> is not really a step forward.

It's no different than what we have, except that we currently have A
being infinite. My patch makes A no longer infinite, but a constant.
Yes that constant is mutable, but it's still a constant, and
controlled by the user. That to me is definitely a BIG step forward.

> 
> and the "last console_sem owner prints all pending messages" rule
> is still there.
> 
> 
> > Or do you have a system that started to suffer from softlockups
> > with this patchset and did not do this before?  
> [..]
> > Do you know about any system where this patch made the softlockup
> > deterministically or statistically more likely, please?  
> 
> I have explained many, many times why my boards die just like before.
> why would I bother collecting any numbers...

Great, and there's cases that die that my patch solves. Lets add my
patch now since it is orthogonal to an offloading approach and see how
it works, because it would solve issues that I have hit. If you can
show that this isn't good enough we can add another approach. We are
solving two different problems. My patch simply makes one printk() no
longer unbounded. It's a fixed time.

Honestly, I don't see why you are against this patch. It doesn't stop
your work. If this patch isn't enough (but it does fix some issues),
then we can look at adding other approaches. Really, it sounds like you
are afraid of this patch, that it might be good enough for most cases
which would make adding another approach even more difficult.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
