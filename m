Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E67A46B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 05:38:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so1779457pff.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 02:38:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d17sor6770882pll.79.2018.01.11.02.38.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 02:38:50 -0800 (PST)
Date: Thu, 11 Jan 2018 19:38:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111103845.GB477@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111093435.GA24497@linux.suse>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/11/18 10:34), Petr Mladek wrote:
[..]
> > except that handing off a console_sem to atomic task when there
> > is   O(logbuf) > watchdog_thresh   is a regression, basically...
> > it is what it is.
> 
> How this could be a regression? Is not the victim that handles
> other printk's random? What protected the atomic task to
> handle the other printks before this patch?

the non-atomic -> atomic context console_sem transfer. we previously
would have kept the console_sem owner to its non-atomic owner. we now
will make sure that if printk from atomic context happens then it will
make it to console_unlock() loop.
emphasis on O(logbuf) > watchdog_thresh.


- if the patch's goal is to bound (not necessarily to watchdog's threshold)
the amount of time we spend in console_unlock(), then the patch is kinda
overcomplicated. but no further questions in this case.

- but if the patch's goal is to bound (to lockup threshold) the amount of
time spent in console_unlock() in order to avoid lockups [uh, a reason],
then the patch is rather oversimplified.


claiming that for any given A, B, C the following is always true

				A * B < C

where
	A is the amount of data to print in the worst case
	B the time call_console_drivers() needs to print a single
	  char to all registered and enabled consoles
	C the watchdog's threshold

is not really a step forward.

and the "last console_sem owner prints all pending messages" rule
is still there.


> Or do you have a system that started to suffer from softlockups
> with this patchset and did not do this before?
[..]
> Do you know about any system where this patch made the softlockup
> deterministically or statistically more likely, please?

I have explained many, many times why my boards die just like before.
why would I bother collecting any numbers...

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
