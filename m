Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 921426B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 04:48:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r1so165375pgt.19
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 01:48:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n19sor99614pgc.97.2018.01.15.01.48.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 01:48:14 -0800 (PST)
Date: Mon, 15 Jan 2018 18:48:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180115094808.GA505@jagdpanzerIV>
References: <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180112125536.GC24497@linux.suse>
 <20180113073100.GB1701@tigerII.localdomain>
 <20180115085115.h73vimlyuuj56be7@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115085115.h73vimlyuuj56be7@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/15/18 09:51), Petr Mladek wrote:
> On Sat 2018-01-13 16:31:00, Sergey Senozhatsky wrote:
> > On (01/12/18 13:55), Petr Mladek wrote:
> > [..]
> > > > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > > > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > > > PREEMPT kernels than !PREEMPT ones.
> > > 
> > > I would say that the patch improves also console_unlock() but only in
> > > non-preemttive context.
> > > 
> > > By other words, it makes console_unlock() finite in preemptible context
> > > (limited by buffer size). It might still be unlimited in
> > > non-preemtible context.
> > 
> > could you elaborate a bit?
> 
> Ah, I am sorry, I swapped the conditions. I meant that
> console_unlock() is finite in non-preemptible context.

ah, OK.
yes. it sill can be infinite, in preemptible context.

a side note,
no kernel or user space process is designed to loop in console_unlock(),
so infinte console_unlock() still can do some damage. we don't crash the
kernel, but if we somehow bring down the user space process, then things
are not so clear. e.g. when we do lots of handoffs we don't up() the
console_sem, so anything that might be sleeping in TASK_UNINTERRUPTIBLE
on console_sem stays in that uninterruptible state, which possibly can
fire the hung task alarm, which also may be configured to panic() the
kernel (or some other type of watchdog). so panic() is still possible
even if we do hand offs. but that's a completely different topic.


> There are two possibilities if console_unlock() is in atomic context
> and never sleeps. First, if there are new printk() callers, they could
> take over the job. Second. if they are no more callers, the
> current owner will release the lock after processing the existing
> messages. In both situations, the current owner will not handle more
> than the entire buffer. Therefore it is limited. We might argue
> if it is enough. But the point is that it is limited which is
> a step forward. And I think that you already agreed that this
> was a step forward.

yes.
the question whether O(A * B) bound is good enough is still there,
but in the worst case it's still a lockup, just like before [including
cases of accidental hand off from non-atomic context to a atomic one].


> The chance of taking over the lock is lower when console_unlock()
> owner could sleep. But then there is not a danger of a softlockup.
> In each case, this patch did not make it worse. Could we agree
> on this, please?

yes.


> All in all, this patch improved one scenario and did not make
> worse another one. We know that it does not fix everything.
> But it is a step forward. Could we agree on this, please?

yes.
it's iffy. it's a step forward when it's a step forward :)
and the good old lockup/panic in other cases. IMHO.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
