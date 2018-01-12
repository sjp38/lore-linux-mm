Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD6866B0253
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 22:12:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id n2so3700566pgs.0
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 19:12:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z31sor6316474plb.40.2018.01.11.19.12.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jan 2018 19:12:45 -0800 (PST)
Date: Fri, 12 Jan 2018 12:12:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180112031240.GC6419@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111203057.5b1a8f8f@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/11/18 20:30), Steven Rostedt wrote:
[..]
> Today, printk() can print for a time of A * B, where, as you state
> above:
> 
>    A is the amount of data to print in the worst case
>    B the time call_console_drivers() needs to print a single
> 	  char to all registered and enabled consoles
> 
> In the worse case, the current approach is A is infinite. That is,
> printk() never stops, as long as there is a printk happening on another
> CPU before B can finish. A will keep growing. The call to printk() will
> never return. The more CPUs you have, the more likely this will occur.
> All it takes is a few CPUs doing periodic printks. If there is a slow
> console, where the periodic printk on other CPUs occur quicker than the
> first can finish, the first one will be stuck forever. Doesn't take
> much to have this happen.

console_sem owner can stuck in console_unlock() not because of printk-s
happening right now on other CPUs, but because those printk-s could have
happened while console_sem owner was preempted. when it comes back it has
a ton of pending messages.

I said it before - "we stuck in console_unlock() because others CPUs
printk right now a lot" is not always true. we have preemption. and
the "last console_sem owner prints it all" is not good in this case.

> With my patch, A is fixed to the size of the buffer. A single printk()
> can never print more than that. If another CPU comes in and does a
> printk, then it will take over the task of printing, and release the
> first printk.

yes. and "another CPU" that comes to take over has to print all the
pending messages. from whatever context it's currently in. and bringing
A * B below C can be quite tricky, if possible at all (!). most likely
people will just add more touch_nmi_watchdog().

again, I don't disagree on "let's bound printk". yes, we totally
should! but the bound must be realistic if we want to fix the damn
thing (either with printk_kthread, or hand off, or anything else).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
