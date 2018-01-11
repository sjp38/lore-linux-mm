Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD8E56B0266
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 07:03:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id d7so1362813wre.15
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 04:03:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f35si6145273wra.139.2018.01.11.04.03.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 04:03:47 -0800 (PST)
Date: Thu, 11 Jan 2018 13:03:41 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180111120341.GB24419@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-3-pmladek@suse.com>
 <20180110125220.69f5f930@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110125220.69f5f930@vmware.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed 2018-01-10 12:52:20, Steven Rostedt wrote:
> On Wed, 10 Jan 2018 14:24:18 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> 
> > The commit ("printk: Add console owner and waiter logic to load balance
> > console writes") made vprintk_emit() and console_unlock() even more
> > complicated.
> > 
> > This patch extracts the new code into 3 helper functions. They should
> > help to keep it rather self-contained. It will be easier to use and
> > maintain.
> > 
> > This patch just shuffles the existing code. It does not change
> > the functionality.
> > 
> > Signed-off-by: Petr Mladek <pmladek@suse.com>
> > ---
> >  kernel/printk/printk.c | 242 +++++++++++++++++++++++++++++--------------------
> >  1 file changed, 145 insertions(+), 97 deletions(-)
> > 
> > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > index 7e6459abba43..6217c280e6c1 100644
> > --- a/kernel/printk/printk.c
> > +++ b/kernel/printk/printk.c
> > @@ -86,15 +86,8 @@ EXPORT_SYMBOL_GPL(console_drivers);
> >  static struct lockdep_map console_lock_dep_map = {
> >  	.name = "console_lock"
> >  };
> > -static struct lockdep_map console_owner_dep_map = {
> > -	.name = "console_owner"
> > -};
> >  #endif
> >  
> > -static DEFINE_RAW_SPINLOCK(console_owner_lock);
> > -static struct task_struct *console_owner;
> > -static bool console_waiter;
> > -
> >  enum devkmsg_log_bits {
> >  	__DEVKMSG_LOG_BIT_ON = 0,
> >  	__DEVKMSG_LOG_BIT_OFF,
> > @@ -1551,6 +1544,143 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
> >  }
> >  
> >  /*
> > + * Special console_lock variants that help to reduce the risk of soft-lockups.
> > + * They allow to pass console_lock to another printk() call using a busy wait.
> > + */
> > +
> > +#ifdef CONFIG_LOCKDEP
> > +static struct lockdep_map console_owner_dep_map = {
> > +	.name = "console_owner"
> > +};
> > +#endif
> > +
> > +static DEFINE_RAW_SPINLOCK(console_owner_lock);
> > +static struct task_struct *console_owner;
> > +static bool console_waiter;
> > +
> > +/**
> > + * console_lock_spinning_enable - mark beginning of code where another
> > + *	thread might safely busy wait
> > + *
> > + * This might be called in sections where the current console_lock owner
> 
> 
> "might be"? It has to be called in sections where the current
> console_lock owner can not sleep. It's basically saying "console lock is
> now acting like a spinlock".

I am afraid that both explanations are confusing. Your one sounds like
it must be called every time we enter non-preemptive context in
console_unlock. What about the following?

 * This is basically saying that "console lock is now acting like
 * a spinlock". It can be called _only_ in sections where the current
 * console_lock owner could not sleep. Also it must be ready to hand
 * over the lock at the end of the section.

> > + * cannot sleep. It is a signal that another thread might start busy
> > + * waiting for console_lock.
> > + */

All the other changes look good to me. I will use them in the next version.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
