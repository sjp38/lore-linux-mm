Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B45D56B027E
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:23:32 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id a12so1783548pll.21
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 22:23:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6sor7150561pgu.192.2017.11.27.22.23.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 22:23:31 -0800 (PST)
Date: Tue, 28 Nov 2017 15:23:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171128062326.GA1907@jagdpanzerIV>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171127084822.GA15859@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127084822.GA15859@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, yuwang.yuwang@alibabab-inc.com, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

Hi,

On (11/27/17 17:48), Byungchul Park wrote:
[..]
> > +				/* Owner will clear console_waiter on hand off */
> > +				while (READ_ONCE(console_waiter))
> > +					cpu_relax();
> > +
> > +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> > +				printk_safe_exit_irqrestore(flags);
> > +
> > +				/*
> > +				 * The owner passed the console lock to us.
> > +				 * Since we did not spin on console lock, annotate
> > +				 * this as a trylock. Otherwise lockdep will
> > +				 * complain.
> > +				 */
> > +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> 
> I'm afraid if it's ok even not to lock(or trylock) actually here. Is there
> any problem if you call console_trylock() instead of mutex_acquire() here?

console_trylock() will not work. console_trylock() implies that the
current printing process does up(), which a) opens a race with possible
console_lock()/console_trylock() from foreign CPUs, and b) additionally
wakes up a task from console_sem wait list [if there was one]. so chances
are some other CPU potentially can acquire the lock ahead of waiter,
forcing the waiter to continue spinning on console_sem. and the bad news
are a) it's spinning with local IRQs disabled and b) that another CPU,
which has acquired the console_sem, can schedule under console_sem.


anyway, we are not going to merge this patch. we already have discussed
that in V3 thread:

https://marc.info/?l=linux-kernel&m=151019815721161&w=2
https://marc.info/?l=linux-kernel&m=151020275921953&w=2
https://marc.info/?l=linux-kernel&m=151020404622181&w=2
https://marc.info/?l=linux-kernel&m=151020565222469&w=2


I took some parts of the Steven's patch set, tho, and backported them
to the current printk_kthread series.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
